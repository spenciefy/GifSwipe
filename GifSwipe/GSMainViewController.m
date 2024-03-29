//
//  GSMainViewController.m
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import "GSMainViewController.h"
#import "GSGifManager.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "Reachability.h"
#import "UIImage+animatedGIF.h"
#import "GSLikedGifsCollectionViewController.h"
#import <Mixpanel/Mixpanel.h>

@interface GSMainViewController ()

@property (nonatomic, strong) NSMutableArray *gifs;

@end

@implementation GSMainViewController {
    BOOL isFirstLaunch;
    BOOL currentlyAddingGifs;
    UILabel *nullStateLabel;
    FLAnimatedImageView *nullStateImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstLaunch = NO;
    currentlyAddingGifs = NO;
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    [GSGifManager sharedInstance].displayedGifIDs = [[NSMutableArray alloc]init];
}

- (void)setupMainView {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        isFirstLaunch = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //Load front and back views
        self.welcomeGifView = [self popOnboardingWelcomeViewWithFrame:[self frontGifViewFrame]];
        self.instructionsGifView = [self popOnboardingInstructionsViewWithFrame:[self backGifViewFrame]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update UI on main thread
            self.welcomeGifView.alpha = 0;
            self.instructionsGifView.alpha = 0;
            [self.view addSubview:self.welcomeGifView];
            [self.view insertSubview:self.instructionsGifView belowSubview:self.welcomeGifView];
            
            [UIView animateWithDuration:0.3f animations:^{
                self.welcomeGifView.alpha = 1;
                self.instructionsGifView.alpha = 1;
            }];
        });
    } else {
        UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
        self.navigationItem.leftBarButtonItem = refreshBarButtonItem;
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"displayedGifIDs"];
    if(data) {
        [GSGifManager sharedInstance].displayedGifIDs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"loaded displayedGifIDs: %@",  [GSGifManager sharedInstance].displayedGifIDs);
    }
    
    //Load liked gifs from defaults
    [GSGifManager sharedInstance].likedGifs = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"likedGifs"]];
    if(![GSGifManager sharedInstance].likedGifs) {
        [GSGifManager sharedInstance].likedGifs = [[NSMutableArray alloc] init];
    }
    
    [[GSGifManager sharedInstance] fetchGifsFrom:@"0" limit:@"10" new:NO withCompletionBlock:^(NSArray *gifs, NSArray *gifIDs, NSError *error) {
        if(!error){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSLog(@"Got first batch of gifs: %lu", (unsigned long)[GSGifManager sharedInstance].gifs.count);

                //Load front and back views
                self.frontGifView = [self popGifViewWithFrame:[self frontGifViewFrame]];
                self.backGifView = [self popGifViewWithFrame:[self backGifViewFrame]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update UI on main thread
                    self.frontGifView.alpha = 0;
                    self.backGifView.alpha = 0;
                    [self.view addSubview:self.frontGifView];
                    [self.view sendSubviewToBack:self.frontGifView];
                    [self.view sendSubviewToBack:nullStateImageView];
                    [self.view sendSubviewToBack:nullStateLabel];
                    [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        self.frontGifView.alpha = 1;
                        self.backGifView.alpha = 1;
                    }];
                    if(!isFirstLaunch) {
                        UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
                        self.navigationItem.leftBarButtonItem = shareBarButtonItem;
                        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
                        [self.navigationItem.leftBarButtonItem setEnabled:YES];
                    }
                    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(checkIfNeedToReload:) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                });

                if(!currentlyAddingGifs) {
                    [self loadMoreGifs];
                }
            });
        } else {
            //Error in fetching
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setNullStateNoConnection];
                nullStateLabel.text = @"Something went wrong when trying to find gifs. Try quitting the app.";
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hasNetwork];
        [self becomeFirstResponder];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self.frontGifView mdc_swipe:MDCSwipeDirectionRight];
    }
}

- (void)loadMoreGifs {
    if(!currentlyAddingGifs){
        currentlyAddingGifs = YES;
        [[GSGifManager sharedInstance] setLoadGifs:YES];
        [[GSGifManager sharedInstance] startLoadingGifsInBackground];
    }
}


#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

- (void)viewDidCancelSwipe:(UIView *)view {
    //NSLog(@"You couldn't decide on %@.", self.currentGifView.gif.caption);
}

- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Gif Swiped" properties:@{
                                                  @"Gif": self.currentGifView.gif.caption,
                                                  }];
    [self setNullStateLoading];

    if([view isKindOfClass:[GSGifView class]]) {
        if([GSGifManager sharedInstance].gifs.count >= 10) {
            [[GSGifManager sharedInstance] setLoadGifs:NO];
            currentlyAddingGifs = NO;
        } else if ([GSGifManager sharedInstance].gifs.count < 5){
            NSLog(@"Need to load more gifs, gif count is %lu, currentladding: %d",(unsigned long)[GSGifManager sharedInstance].gifs.count, currentlyAddingGifs);
            if(!currentlyAddingGifs){
                [[GSGifManager sharedInstance] setLoadGifs:YES];
                [self loadMoreGifs];
            }
        }
        
        GSGif *gifToMove = self.currentGifView.gif;

        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *gifURL = [NSURL URLWithString:gifToMove.gifLink];
        NSString *gifFileName = [gifURL lastPathComponent];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        NSString *fromGifFinalPath = [documentsDirectory stringByAppendingPathComponent:gifFileName];
        NSString *toGifFolderPath = [documentsDirectory stringByAppendingPathComponent:@"liked_gifs"];
        NSString *toGifFinalPath = [toGifFolderPath stringByAppendingPathComponent:gifFileName];
        
        if (direction == MDCSwipeDirectionRight) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSError *error;
                BOOL isDirectory;
                if(![manager fileExistsAtPath:toGifFolderPath isDirectory:&isDirectory]){
                    if(!isDirectory)
                        [manager createDirectoryAtPath:toGifFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
                }
                
                if(![manager fileExistsAtPath:toGifFinalPath] && [manager fileExistsAtPath:fromGifFinalPath]) {
                    [[GSGifManager sharedInstance].likedGifs addObject:gifToMove];
                    [manager moveItemAtPath:fromGifFinalPath toPath:toGifFinalPath error:&error];
                    if(error) {
                       // NSLog(@"Error in moving liked gif %@", error.description);
                    } else {
                        NSLog(@"Moved liked gif %@ to %@", gifFileName, toGifFinalPath);
                    }
                }

                NSData *data = [NSKeyedArchiver archivedDataWithRootObject: [[GSGifManager sharedInstance].likedGifs mutableCopy]];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:data forKey:@"likedGifs"];
                [defaults synchronize];
            });
        } else {

            NSString *gifFileLocation = [documentsDirectory stringByAppendingPathComponent:gifFileName];
            NSError *error;
            BOOL success = [manager removeItemAtPath:gifFileLocation error:&error];
            if (success) {
              //  NSLog(@"removed noped gif, %@", self.currentGifView.gif.caption);
            } else {
              //   NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
            }
        }
        
        if(!self.backGifView) {
            self.currentGifView = nil;
            [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
        }
        if(self.currentGifView) {
            [[GSGifManager sharedInstance].displayedGifIDs addObject:self.currentGifView.gif.gifID];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject: [GSGifManager sharedInstance].displayedGifIDs];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:@"displayedGifIDs"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //  NSLog(@"Saved displayedGifIDs in userdefaults: %@", [GSGifManager sharedInstance].displayedGifIDs);
        }
        
        self.frontGifView = self.backGifView;
        
        if([[GSGifManager sharedInstance].gifs count] > 2){
            if(!self.frontGifView) {
                self.frontGifView = [self popGifViewWithFrame:[self frontGifViewFrame]];
                self.backGifView = [self popGifViewWithFrame:[self backGifViewFrame]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update UI on main thread
                    self.frontGifView.alpha = 0;
                    self.backGifView.alpha = 0;
                    [self.view addSubview:self.frontGifView];
                    [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        self.frontGifView.alpha = 1;
                        self.backGifView.alpha = 1;
                    }];
                    UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
                    self.navigationItem.leftBarButtonItem = shareBarButtonItem;
                    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
                    [self.navigationItem.leftBarButtonItem setEnabled:YES];
                });
            } else {
                self.backGifView = [self popGifViewWithFrame:[self backGifViewFrame]];
                self.backGifView.frame = [self backGifViewFrame];
                self.backGifView.alpha = 0.f;
                [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
                [UIView animateWithDuration:0.5
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.backGifView.alpha = 1.f;
                                 } completion:nil];
            }
            
        } else {
            self.backGifView = nil;
        }
        
        NSLog(@"number of gifs: %lu", (unsigned long)[[GSGifManager sharedInstance].gifs count]);
    } else if([view isKindOfClass:[GSOnboardingInstructionsView class]]){
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
}


- (void)checkIfNeedToReload:(id)sender {
    if(self.backGifView == nil && self.frontGifView == nil) {
        UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
        self.navigationItem.leftBarButtonItem = refreshBarButtonItem;
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        
        if([GSGifManager sharedInstance].gifs.count >= 3) {
            //Load front and back views
            self.frontGifView = [self popGifViewWithFrame:[self frontGifViewFrame]];
            self.backGifView = [self popGifViewWithFrame:[self backGifViewFrame]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update UI on main thread
                self.frontGifView.alpha = 0;
                self.backGifView.alpha = 0;
                [self.view addSubview:self.frontGifView];
                [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
                
                [UIView animateWithDuration:0.3f animations:^{
                    self.frontGifView.alpha = 1;
                    self.backGifView.alpha = 1;
                }];
                UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
                self.navigationItem.leftBarButtonItem = shareBarButtonItem;
                [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
                [self.navigationItem.leftBarButtonItem setEnabled:YES];
            });
        }
    } else if(self.backGifView == nil){
        self.backGifView = [self popGifViewWithFrame:[self backGifViewFrame]];
        self.backGifView.frame = [self backGifViewFrame];
        self.backGifView.alpha = 0.f;
        [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backGifView.alpha = 1.f;
                         } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontGifView:(GSGifView *)frontGifView {
    _frontGifView = frontGifView;
    self.currentGifView = frontGifView;
}

- (GSGifView *)popGifViewWithFrame:(CGRect)frame {
    if ([GSGifManager sharedInstance].gifs.count == 0) {
        return nil;
    }
    
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 110.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backGifViewFrame];
        self.backGifView.frame = CGRectMake(frame.origin.x,
                                            frame.origin.y - (state.thresholdRatio * 10.f),
                                            CGRectGetWidth(frame),
                                            CGRectGetHeight(frame));
    };
    options.likedText = @"LIKE";
    options.nopeText = @"NOPE";
    options.likedColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1];
    options.nopeColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
    
    GSGifView *gifView = [[GSGifView alloc] initWithFrame:frame gif:[GSGifManager sharedInstance].gifs[0] options:options];
    [[GSGifManager sharedInstance].gifs removeObjectAtIndex:0];
    return gifView;
}


- (GSGifView *)fetchNextBackGifView {
    CGRect frame = [self backGifViewFrame];
    if ([GSGifManager sharedInstance].gifs.count == 0) {
        return nil;
    }
    
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 110.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backGifViewFrame];
        self.backGifView.frame = CGRectMake(frame.origin.x,
                                            frame.origin.y - (state.thresholdRatio * 10.f),
                                            CGRectGetWidth(frame),
                                            CGRectGetHeight(frame));
    };
    options.likedText = @"LIKE";
    options.nopeText = @"NOPE";
    options.likedColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1];
    options.nopeColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
    GSGifView *gifView = [[GSGifView alloc] initWithFrame:frame gif:[GSGifManager sharedInstance].gifs[0] options:options];
    [[GSGifManager sharedInstance].gifs removeObjectAtIndex:0];
    return gifView;
}

- (GSOnboardingWelcomeView *)popOnboardingWelcomeViewWithFrame:(CGRect)frame {
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 110.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backGifViewFrame];
        self.instructionsGifView.frame = CGRectMake(frame.origin.x,
                                            frame.origin.y - (state.thresholdRatio * 10.f),
                                            CGRectGetWidth(frame),
                                            CGRectGetHeight(frame));
    };
    GSOnboardingWelcomeView *welcomeOnboardingView = [[GSOnboardingWelcomeView alloc] initWithFrame:frame options:options];
    return welcomeOnboardingView;
}

- (GSOnboardingInstructionsView *)popOnboardingInstructionsViewWithFrame:(CGRect)frame {
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 110.f;

    GSOnboardingInstructionsView *instructionsOnboardingView = [[GSOnboardingInstructionsView alloc] initWithFrame:frame options:options];
    return instructionsOnboardingView;
}
                       
- (CGRect)frontGifViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 90.f;
    CGFloat bottomPadding = 120.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backGifViewFrame {
    CGRect frontFrame = [self frontGifViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

- (void)setupNullState{
    nullStateImageView = [[FLAnimatedImageView alloc] init];
    nullStateImageView.frame = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 30, 250, 160);
    nullStateImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50);
    nullStateImageView.contentMode = UIViewContentModeScaleToFill;
    NSString *path=[[NSBundle mainBundle]pathForResource:@"searching" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    nullStateImageView.animatedImage = gifImage;
    [self.view addSubview:nullStateImageView];
    
    nullStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700)];
    nullStateLabel.center = CGPointMake(nullStateImageView.center.x, nullStateLabel.center.y);
    nullStateLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:25];
    nullStateLabel.textColor = [UIColor darkGrayColor];//[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
    nullStateLabel.numberOfLines = 0;
    nullStateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nullStateLabel.textAlignment = NSTextAlignmentCenter;
    nullStateLabel.text = @"Finding a batch of Gifs for you :)";
    nullStateLabel.adjustsFontSizeToFitWidth = YES;
    [nullStateLabel sizeToFit];
    if(isFirstLaunch) {
        nullStateImageView.alpha = 0;
        nullStateLabel.alpha = 0;
    }
    
    [self.view addSubview:nullStateLabel];
    [self.view sendSubviewToBack:nullStateImageView];
    [self.view sendSubviewToBack:nullStateLabel];
}

- (void)setNullStateLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        nullStateImageView.alpha = 1;
        nullStateLabel.alpha = 1;
        NSString *path=[[NSBundle mainBundle]pathForResource:@"searching" ofType:@"gif"];
        NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
        
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
        nullStateImageView.animatedImage = gifImage;
        nullStateLabel.text = @"Finding some more Gifs for you :)";
        nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);
        nullStateLabel.adjustsFontSizeToFitWidth = YES;
        [nullStateLabel sizeToFit];
    });
}

- (void)setNullStateNoConnection {
    dispatch_async(dispatch_get_main_queue(), ^{
        nullStateImageView.alpha = 1;
        nullStateLabel.alpha = 1;
        nullStateLabel.text = @"You're not connected to the internet :(";
        NSString *path=[[NSBundle mainBundle]pathForResource:@"sad" ofType:@"gif"];
        NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
        
        nullStateImageView.animatedImage = gifImage;

        nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);
        nullStateLabel.adjustsFontSizeToFitWidth = YES;
        [nullStateLabel sizeToFit];
        
        UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshNetworkAction:)];
        self.navigationItem.leftBarButtonItem = refreshBarButtonItem;
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    });
}

- (void)hasNetwork {
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    if(myStatus == NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [self setupNullState];
        [self setNullStateNoConnection];
        });
    } else{
        if(myStatus == ReachableViaWWAN) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hm..." message:@"Looks like you're connected via cellular data. This app uses A LOT of data (downloading large 2-10 MB sized gifs), so beware!" delegate:self cancelButtonTitle:@"I'm willing to use my data." otherButtonTitles:@"Hm.. I don't have much data.", nil];
            [alert show];
        } else if(myStatus == ReachableViaWiFi) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupNullState];
            });
            [self setupMainView];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex == buttonIndex){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupNullState];
            [self setupMainView];
        });
    }
    if (buttonIndex == 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupNullState];
            [self setNullStateNoConnection];
        });
    }
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}


- (IBAction)shareAction:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Share" properties:@{@"Gif": self.currentGifView.gif.caption,}];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *shareString = [NSString stringWithFormat:@"Check out this Gif I found via GifSwipe!\r\r%@\r",self.currentGifView.gif.caption];
        [self shareText:shareString andImage:nil andUrl:[NSURL URLWithString:self.currentGifView.gif.gifLink]];
    });
}

- (IBAction)refreshNetworkAction:(id)sender {
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    if(myStatus == NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            nullStateLabel.text = @"You still don't have internet. :(";
        });
    } else{
        if(myStatus == ReachableViaWWAN) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hm..." message:@"Looks like you're connected via cellular data. This app uses A LOT of data (downloading large 2-10 MB sized gifs), so beware!" delegate:self cancelButtonTitle:@"I'm willing to use my data." otherButtonTitles:@"Hm.. I don't have much data.", nil];
            [alert show];
        } else if(myStatus == ReachableViaWiFi) {
            [self setupMainView];
        }
    }
}

- (IBAction)refreshAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch(arc4random_uniform(7)) {
            case 0: {
                nullStateLabel.text = @"Be patient, be patient. Finding funny gifs is not an easy job.";
                nullStateLabel.frame =  CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700);
                nullStateLabel.adjustsFontSizeToFitWidth = YES;
                [nullStateLabel sizeToFit];
                nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);

                NSString *path=[[NSBundle mainBundle]pathForResource:@"nullstate" ofType:@"gif"];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                
                FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
                nullStateImageView.animatedImage = gifImage;
                
                break;
            }
            case 1: {
                nullStateLabel.text = @"This app is slow because of the dude who made it. Blame him.";
                nullStateLabel.frame =  CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700);
                nullStateLabel.adjustsFontSizeToFitWidth = YES;
                [nullStateLabel sizeToFit];
                nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);

                NSString *path=[[NSBundle mainBundle]pathForResource:@"heythere" ofType:@"gif"];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
                nullStateImageView.animatedImage = gifImage;
                break;
            }
            case 2: {
                nullStateLabel.text = @"Should you really be using this app right now? Nothing better to do?";
                nullStateLabel.frame =  CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700);
                nullStateLabel.adjustsFontSizeToFitWidth = YES;
                [nullStateLabel sizeToFit];
                nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);

                NSString *path=[[NSBundle mainBundle]pathForResource:@"searching" ofType:@"gif"];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                
                FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
                nullStateImageView.animatedImage = gifImage;
                break;}
            case 3: {
                nullStateLabel.text = @"You are using a Tinder for gifs app. Perhaps you should reconsider your life.";
                nullStateLabel.frame =  CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700);
                nullStateLabel.adjustsFontSizeToFitWidth = YES;
                [nullStateLabel sizeToFit];
                nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);

                NSString *path=[[NSBundle mainBundle]pathForResource:@"sad" ofType:@"gif"];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                
                FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
                nullStateImageView.animatedImage = gifImage;
                break;
            }
            case 4: {
                nullStateLabel.text = @"Sincere apologies for the slow loading times. ";
                nullStateLabel.frame =  CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700);
                nullStateLabel.adjustsFontSizeToFitWidth = YES;
                [nullStateLabel sizeToFit];
                nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);

                NSString *path=[[NSBundle mainBundle]pathForResource:@"thereisnoneedtobeupset" ofType:@"gif"];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
                nullStateImageView.animatedImage = gifImage;
                break;
            }
            case 5: {
                nullStateLabel.text = @"I made this slow just because I have a monopoly over the Tinder for gifs market.";
                nullStateLabel.frame =  CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700);
                nullStateLabel.adjustsFontSizeToFitWidth = YES;
                [nullStateLabel sizeToFit];
                nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);


                NSString *path=[[NSBundle mainBundle]pathForResource:@"thereisnoneedtobeupset" ofType:@"gif"];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
                nullStateImageView.animatedImage = gifImage;
                break;
            }
            case 6: {
                nullStateLabel.text = @"^^^^";
                nullStateLabel.frame =  CGRectMake(nullStateImageView.frame.origin.x,nullStateImageView.frame.origin.y + nullStateImageView.frame.size.height + 10, 300, 700);
                nullStateLabel.adjustsFontSizeToFitWidth = YES;
                [nullStateLabel sizeToFit];
                nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), nullStateLabel.center.y);
                
                NSString *path=[[NSBundle mainBundle]pathForResource:@"now-is-the-time-to-be-upset" ofType:@"gif"];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
                nullStateImageView.animatedImage = gifImage;
                break;
            }
        }
    
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"likedSegue"]){
        GSLikedGifsCollectionViewController *likedCollectionVC = [segue destinationViewController];
        likedCollectionVC.likedGifs = [[GSGifManager sharedInstance].likedGifs mutableCopy];
    }
}
@end

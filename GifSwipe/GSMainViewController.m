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

@interface GSMainViewController ()

@property (nonatomic, strong) NSMutableArray *gifs;
@property (nonatomic, strong) NSMutableArray *likedGifs;

@end

@implementation GSMainViewController {
    BOOL currentlyAddingGifs;
    UILabel *nullStateLabel;
    FLAnimatedImageView *nullStateImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentlyAddingGifs = NO;
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    self.likedGifs = [[NSMutableArray alloc]init];

    
    [GSGifManager sharedInstance].displayedGifIDs = [[NSMutableArray alloc]init];
}

- (void)setupMainView {
#warning temporarily commented out so its easier to load stuff... overlap
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    NSData *data = [defaults objectForKey:@"displayedGifIDs"];
    //    if(data) {
    //    [GSGifManager sharedInstance].displayedGifIDs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //    NSLog(@"loaded displayedGifIDs: %@",  [GSGifManager sharedInstance].displayedGifIDs);
    //    }
    
    //Load liked gifs from defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.likedGifs = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"likedGifs"]];
    if(!self.likedGifs) {
        self.likedGifs = [[NSMutableArray alloc] init];
    }
    
    [[GSGifManager sharedInstance] fetchGifsFrom:@"0" limit:@"5" new:NO withCompletionBlock:^(NSArray *gifs, NSArray *gifIDs, NSError *error) {
        if(!error){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSLog(@"Got first batch of gifs: %lu", (unsigned long)[GSGifManager sharedInstance].gifs.count);
            
                if([GSGifManager sharedInstance].gifs.count < 4) {
                    NSLog(@"Loading more gif views because not enough gifs found");
                    currentlyAddingGifs = YES;
                    [self loadMoreGifs];
                }

                //Load front and back views
                self.frontGifView = [self popGifViewWithFrame:[self frontGifViewFrame]];
                self.backGifView = [self popGifViewWithFrame:[self backGifViewFrame]];
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Updating UI now");
                        //Update UI on main thread
                        self.frontGifView.alpha = 0;
                        self.backGifView.alpha = 0;
                        [self.view addSubview:self.frontGifView];
                        [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
                        
                        [UIView animateWithDuration:0.3f animations:^{
                            self.frontGifView.alpha = 1;
                            self.backGifView.alpha = 1;
                        }];
                        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
                        [self.navigationItem.leftBarButtonItem setEnabled:YES];
                    });

                if(!currentlyAddingGifs) {
                    [self loadMoreGifs];
                }
            });
        } else {
            //Error in fetching
            dispatch_async(dispatch_get_main_queue(), ^{
            [self setNullStateNoConnection];
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
        
        [self setupNullState];
        if([self hasNetwork]) {
            [self setupMainView];
        } else {
            [self setNullStateNoConnection];
        }
        
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

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    //NSLog(@"You couldn't decide on %@.", self.currentGifView.gif.caption);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    [self setNullStateLoading];

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
    
    if (direction == MDCSwipeDirectionRight) {
        [self.likedGifs addObject:self.currentGifView.gif];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject: [self.likedGifs mutableCopy]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:@"likedGifs"];
            [defaults synchronize];
        });
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:self.currentGifView.gif.gifFileLocation error:&error];
        if (success) {
            NSLog(@"removed noped gif, %@", self.currentGifView.gif.caption);
        } else {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
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
    
    if([[GSGifManager sharedInstance].gifs count] > 0){
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
        
    } else {
        self.backGifView = nil;
    }
    
    NSLog(@"number of gifs: %lu", (unsigned long)[[GSGifManager sharedInstance].gifs count]);
    
    
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
    options.threshold = 160.f;
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
    options.threshold = 160.f;
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
    nullStateImageView.frame = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20, 250, 200);
    nullStateImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50);
    nullStateImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSString *path=[[NSBundle mainBundle]pathForResource:@"searching" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    nullStateImageView.animatedImage = gifImage;
    [self.view addSubview:nullStateImageView];
    
    nullStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 30, 300, 500)];
    nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 80);
    nullStateLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:30];
    nullStateLabel.textColor = [UIColor darkGrayColor];//[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
    nullStateLabel.numberOfLines = 5;
    nullStateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nullStateLabel.textAlignment = NSTextAlignmentCenter;
    nullStateLabel.text = @"Finding a batch of Gifs for you :)";
    
    [self.view addSubview:nullStateLabel];
    [self.view sendSubviewToBack:nullStateImageView];
    [self.view sendSubviewToBack:nullStateLabel];
}

- (void)setNullStateLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *path=[[NSBundle mainBundle]pathForResource:@"searching" ofType:@"gif"];
        NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
        
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
        nullStateImageView.animatedImage = gifImage;
        
        nullStateLabel.text = @"Finding some more Gifs for you :)";
        
        nullStateImageView.frame = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20, 250, 200);
        nullStateImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50);
        
    });
}

- (void)setNullStateNoConnection {
    dispatch_async(dispatch_get_main_queue(), ^{
        nullStateImageView.frame = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20, 199, 142);
        nullStateLabel.text = @"You're not connected to the internet :(";
        NSString *path=[[NSBundle mainBundle]pathForResource:@"sad" ofType:@"gif"];
        NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
        nullStateImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50);
        
        nullStateImageView.animatedImage = gifImage;
        
    });
}

- (BOOL)hasNetwork {
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    if(myStatus == NotReachable) {
        return NO;
    } else{
        if(myStatus == ReachableViaWWAN) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hm..." message:@"Seems like you're connected via cellular data. This app uses A LOT of data (downloading large gifs), so beware!" delegate:self cancelButtonTitle:@"Got it." otherButtonTitles:nil];
            [alert show];
        } else if(myStatus == ReachableViaWiFi) {
        
        }
        return YES;
    }
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *shareString = [NSString stringWithFormat:@"Check out this Gif I found via GifSwipe!\r\r%@\r",self.currentGifView.gif.caption];
        [self shareText:shareString andImage:nil andUrl:[NSURL URLWithString:self.currentGifView.gif.gifLink]];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue from main view");
    if([[segue identifier] isEqualToString:@"likedSegue"]){
        GSLikedGifsCollectionViewController *likedCollectionVC = [segue destinationViewController];
        likedCollectionVC.likedGifs = self.likedGifs;
    }
}
@end

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
@property (nonatomic, strong) NSMutableArray *gifViews;
@property (nonatomic, strong) NSMutableArray *addedGifViewIDs;
@property (nonatomic, strong) NSMutableArray *likedGifs;

@end

@implementation GSMainViewController {
    BOOL currentlyAddingViews;
    int gifCount;
    UILabel *nullStateLabel;
    FLAnimatedImageView *nullStateImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    currentlyAddingViews = NO;
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

- (void)setupMainView {
    [[GSGifManager sharedInstance] fetchGifsFrom:@"0" limit:@"50" new:NO withCompletionBlock:^(NSArray *gifs, NSArray *gifIDs, NSError *error) {
            if(!error){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

                gifCount = 50;
                self.frontGifView = [self popGifViewWithFrame:[self frontGifViewFrame]];
                
                self.backGifView = [self fetchNextGifView];
                self.addedGifViewIDs = [@[self.frontGifView.gif.gifID, self.backGifView.gif.gifID] mutableCopy];
                self.gifViews = [@[self.backGifView] mutableCopy];
                self.likedGifs = [[NSMutableArray alloc]init];
            dispatch_async(dispatch_get_main_queue(), ^{
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
                for(int i = 0; i < 5; i++) {
                    GSGifView *gifView = [self fetchNextGifView];
                    if(gifView && ![self.addedGifViewIDs containsObject:gifView.gif.gifID]) {
                        [self.addedGifViewIDs addObject:gifView.gif.gifID];
                        [self.gifViews addObject:gifView];
                        NSLog(@"added gifview:%@", gifView.gif.caption);
                    } else {
                        NSLog(@"error: %@", gifView.gif.caption);
                    }
                }
                [self loadMoreGifViews];
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

- (void)loadMoreGifViews {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if(!currentlyAddingViews){
        if([GSGifManager sharedInstance].gifs.count >= 20) {
            if(self.gifViews.count < 10) {
                currentlyAddingViews = YES;
                for(int i = 0; i < 15; i++) {
                     GSGifView *gifView = [self fetchNextGifView];
                        if(gifView) {
                            [self.gifViews addObject:gifView];
                            NSLog(@"added gifview:%@", gifView.gif.caption);
                            
                            if(self.gifViews.count > 1 && !self.currentGifView) {
                                [self loadNewFrontBackViews];
                            }
                        } else {
                            NSLog(@"error: %@", gifView.gif.caption);
                        }
                        if(i == 14) {
                            currentlyAddingViews = NO;
                            [self loadMoreGifViews];
                        }
                }
            }
        } else {
            [[GSGifManager sharedInstance] loadGifsWithCompletionBlock:^(NSArray *gifs, NSError *error) {
                [self loadMoreGifViews];
            }];
        }
        }
    });
    
}

- (void)loadNewFrontBackViews {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1]];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        
        self.frontGifView = self.gifViews[0];
        self.frontGifView.frame = [self frontGifViewFrame];
        self.frontGifView.alpha = 0.f;
        [self.view addSubview:self.frontGifView];
    
        self.backGifView = self.gifViews[1];
        self.backGifView.frame = [self backGifViewFrame];
        self.backGifView.alpha = 0.f;
        [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.frontGifView.alpha = 1;
            self.backGifView.alpha = 1;
        }];
        
        [self.gifViews removeObjectAtIndex:0];
    });
}


#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentGifView.gif.caption);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {    
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentGifView.gif.caption);
    } else {
        [self.likedGifs addObject:self.currentGifView];
        NSLog(@"You liked %@.", self.currentGifView.gif.caption);
    }
    
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    [self setNullStateLoading];
    
    if(!self.backGifView) {
        self.currentGifView = nil;
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
    
    if([self.gifViews count] > 0){
        [self.gifViews removeObjectAtIndex:0];
        self.frontGifView = self.backGifView;
    }
    if([self.gifViews count] > 0){
        [[GSGifManager sharedInstance].displayedGifIDs addObject:self.currentGifView.gif.gifID];
        self.backGifView = self.gifViews[0];
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
        [self loadMoreGifViews];
    }

    // Fade the back card into view.
    NSLog(@"front is now: %@, back is now %@", self.frontGifView.gif.caption, self.backGifView.gif.caption);
    NSLog(@"number of views in array: %lu", (unsigned long)self.gifViews.count);

    
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
    options.likedText = @"like";
    options.nopeText = @"nope";
    options.likedColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1];
    options.nopeColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
    
    GSGifView *gifView = [[GSGifView alloc] initWithFrame:frame gif:[GSGifManager sharedInstance].gifs[0] options:options];
    [[GSGifManager sharedInstance].gifs removeObjectAtIndex:0];
    return gifView;
}


- (GSGifView *)fetchNextGifView {
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

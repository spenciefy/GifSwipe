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

@interface GSMainViewController ()

@property (nonatomic, strong) NSMutableArray *gifs;

@end

@implementation GSMainViewController {
    BOOL swipeToRight;
    UILabel *nullStateLabel;
    FLAnimatedImageView *nullStateImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNullState];
    
    swipeToRight = NO;
    [[GSGifManager sharedInstance] fetchGifsWithCompletionBlock:^(NSArray *gifs, NSError *error) {
        self.gifs = [gifs mutableCopy];
        self.frontGifView = [self popGifViewWithFrame:[self frontGifViewFrame]];
        [self.view addSubview:self.frontGifView];
        
        self.backGifView = [self popGifViewWithFrame:[self backGifViewFrame]];
        [self.view insertSubview:self.backGifView belowSubview:self.frontGifView];
        
        self.thirdGifView = [self popGifViewWithFrame:[self thirdGifViewFrame]];
        [self.view insertSubview:self.thirdGifView belowSubview:self.backGifView];

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
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"lol shake");
        if(swipeToRight) {
            [self.frontGifView mdc_swipe:MDCSwipeDirectionRight];
            swipeToRight = NO;
        }
        else {
            [self.frontGifView mdc_swipe:MDCSwipeDirectionLeft];
            swipeToRight = YES;
        }
    
    }
}
#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentGif.gifLink);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentGif.gifLink);
    } else {
        NSLog(@"You liked %@.", self.currentGif.gifLink);
    }
    
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontGifView = self.backGifView;
    self.backGifView = self.thirdGifView;
    self.backGifView.frame = [self backGifViewFrame];
//    self.thirdGifView = [self popGifViewWithFrame:[self thirdGifViewFrame]];       // Fade the back card into view.
//    self.thirdGifView.alpha = 1.f;
//    [self.view insertSubview:self.thirdGifView belowSubview:self.backGifView];
//    [UIView animateWithDuration:0.2
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             self.thirdGifView.alpha = 1.f;
//                         } completion:nil];
    
}

#pragma mark - Internal Methods

- (void)setfrontGifView:(GSGifView *)frontGifView {
    _frontGifView = frontGifView;
    self.currentGif = frontGifView.gif;
}

- (GSGifView *)popGifViewWithFrame:(CGRect)frame {
    if ([self.gifs count] == 0) {
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
        CGRect thirdFrame = [self thirdGifViewFrame];
        self.thirdGifView.frame = CGRectMake(thirdFrame.origin.x,
                                            thirdFrame.origin.y - (state.thresholdRatio * 7.f),
                                            CGRectGetWidth(thirdFrame),
                                            CGRectGetHeight(thirdFrame));
    };
    
    GSGifView *gifView = [[GSGifView alloc] initWithFrame:frame gif:self.gifs[0] options:options];
    [self.gifs removeObjectAtIndex:0];
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

- (CGRect)thirdGifViewFrame {
    CGRect backFrame = [self backGifViewFrame];
    return CGRectMake(backFrame.origin.x,
                      backFrame.origin.y + 10.f,
                      CGRectGetWidth(backFrame),
                      CGRectGetHeight(backFrame));
}

- (void)setupNullState{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"sad" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];

    nullStateImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20, 199, 142)];
    nullStateImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20);
    nullStateImageView.contentMode = UIViewContentModeScaleAspectFit;
    nullStateImageView.animatedImage = gifImage;
    [self.view addSubview:nullStateImageView];
    
    nullStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 30, 200, 100)];
    nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 20);
    nullStateLabel.text = @"Oh no!";
    nullStateLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:30];
    nullStateLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:nullStateLabel];

}


@end

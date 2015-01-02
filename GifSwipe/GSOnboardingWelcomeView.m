//
//  GSOnboardingWelcomeView.m
//  GifSwipe
//
//  Created by Spencer Yen on 1/2/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "GSOnboardingWelcomeView.h"
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT)

@interface GSOnboardingWelcomeView ()

@property (nonatomic, strong) MDCSwipeToChooseViewOptions *options;

@end

@implementation GSOnboardingWelcomeView

- (instancetype)initWithFrame:(CGRect)frame
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame];
    if (self) {
        _options = options ? options : [MDCSwipeToChooseViewOptions new];
        self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1].CGColor;
        [self constructView];
        [self setupSwipeToChoose];
    }
    return self;
}

- (void)constructView {
    _titleLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    _titleLabel.center = CGPointMake(self.frame.size.width/2, 50);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor darkGrayColor];
    _titleLabel.text = @"Hey there!";
    _titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:44];
    [self addSubview:_titleLabel];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"heythere" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    
    _gifImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/1.2, (self.frame.size.width/1.2)/1.81)];
    _gifImageView.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height/2) - 50);
    _gifImageView.animatedImage = gifImage;
    if(IS_IPHONE_4_OR_LESS) {
        _titleLabel.center = CGPointMake(self.frame.size.width/2, 40);
        _gifImageView.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height/2) - 40);

    }
    [self addSubview:_gifImageView];
    
    _captionLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
    _captionLabel.center = CGPointMake(self.frame.size.width/2, _gifImageView.frame.origin.y + _gifImageView.frame.size.height + 60);
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    _captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _captionLabel.textColor = [UIColor darkGrayColor];
    _captionLabel.text = @"GifSwipe finds you fun Gifs to browse through.";
    _captionLabel.numberOfLines = 2;
    _captionLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:28];
    [self addSubview:_captionLabel];
    
    _bottomInstructionsLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 25)];
    _bottomInstructionsLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - 30);
    _bottomInstructionsLabel.textAlignment = NSTextAlignmentCenter;
    _bottomInstructionsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _bottomInstructionsLabel.textColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];//[UIColor lightGrayColor];
    _bottomInstructionsLabel.text = @"(Swipe right to get started)";
    _bottomInstructionsLabel.numberOfLines = 1;
    _bottomInstructionsLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    [self addSubview:_bottomInstructionsLabel];
}

- (void)setupSwipeToChoose {
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;
    __weak GSOnboardingWelcomeView *weakself = self;
    options.onPan = ^(MDCPanState *state) {
        if (state.direction == MDCSwipeDirectionNone) {
            
        } else if (state.direction == MDCSwipeDirectionLeft) {
            
        } else if (state.direction == MDCSwipeDirectionRight) {
            
        }
        
        if (weakself.options.onPan) {
            weakself.options.onPan(state);
        }
    };
    
    [self mdc_swipeToChooseSetup:options];
}

@end

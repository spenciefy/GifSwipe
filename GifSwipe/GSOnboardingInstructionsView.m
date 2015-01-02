//
//  GSOnboardingInstructionsView.m
//  GifSwipe
//
//  Created by Spencer Yen on 1/2/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "GSOnboardingInstructionsView.h"
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
@interface GSOnboardingInstructionsView ()

@property (nonatomic, strong) MDCSwipeToChooseViewOptions *options;

@end

@implementation GSOnboardingInstructionsView

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
 
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)];
    
    _titleLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-25, 50)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor darkGrayColor];
    _titleLabel.text = @"It's pretty simple:";
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:37];
    [_mainView addSubview:_titleLabel];
    
    double spacing;
    if(IS_IPHONE_4_OR_LESS) {
        spacing = 5;
        _titleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/20 - 5);
    } else if( IS_IPHONE_5) {
        spacing = 10;
        _titleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/20);
    } else {
        spacing = 25;
        _titleLabel.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height/20)+15);
    }
    
    _swipeRightLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 20, 40)];
    _swipeRightLabel.center = CGPointMake(self.frame.size.width/2, _titleLabel.center.y + 40 + spacing);
    _swipeRightLabel.textAlignment = NSTextAlignmentCenter;
    _swipeRightLabel.textColor = [UIColor colorWithRed:61/255.0 green:176/255.0 blue:44/255.0 alpha:1];
    _swipeRightLabel.text = @"Swipe right if you like the gif";
    _swipeRightLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:24];
    _swipeRightLabel.adjustsFontSizeToFitWidth = YES;
    [_mainView addSubview:_swipeRightLabel];

    _swipeLeftLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 20, 40)];
    _swipeLeftLabel.center = CGPointMake(self.frame.size.width/2,  _swipeRightLabel.center.y + 40 + spacing - 15);
    _swipeLeftLabel.textAlignment = NSTextAlignmentCenter;
    _swipeLeftLabel.textColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
    _swipeLeftLabel.text = @"Swipe left if you don't like it";
    _swipeLeftLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:_swipeRightLabel.font.pointSize];
    _swipeLeftLabel.adjustsFontSizeToFitWidth = YES;
    [_mainView addSubview:_swipeLeftLabel];

    _shareLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 20, 50)];
    _shareLabel.center = CGPointMake(self.frame.size.width/2, _swipeLeftLabel.center.y + 40 + spacing);
    _shareLabel.textAlignment = NSTextAlignmentCenter;
    _shareLabel.textColor = [UIColor lightGrayColor];
    _shareLabel.text = @"You can share Gifs:";
    [_mainView addSubview:_shareLabel];
    
    _shareImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 60)];
    _shareImageView.center = CGPointMake(self.frame.size.width/2, _shareLabel.center.y + 35 + spacing);
    _shareImageView.image = [UIImage imageNamed:@"share.png"];
    [_mainView addSubview:_shareImageView];
    
    _likedLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 20, 50)];
    _likedLabel.center = CGPointMake(self.frame.size.width/2, _shareImageView.center.y + 50 + spacing);
    _likedLabel.textAlignment = NSTextAlignmentCenter;
    _likedLabel.textColor = [UIColor lightGrayColor];
    _likedLabel.text = @"And see Gifs you've liked:";
    _likedLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:23];
    _likedLabel.adjustsFontSizeToFitWidth = YES;
    [_mainView addSubview:_likedLabel];
    
    _shareLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:_likedLabel.font.pointSize];
    
    _likedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 60)];
    _likedImageView.center = CGPointMake(self.frame.size.width/2, _likedLabel.center.y + 35 + spacing);
    _likedImageView.image = [UIImage imageNamed:@"liked.png"];
    [_mainView addSubview:_likedImageView];
    
    _mainView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:_mainView];

    _bottomInstructionsLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 20, 25)];
    _bottomInstructionsLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - 30);
    _bottomInstructionsLabel.textAlignment = NSTextAlignmentCenter;
    _bottomInstructionsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _bottomInstructionsLabel.textColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];//[UIColor lightGrayColor];
    _bottomInstructionsLabel.text = @"(Swipe right to start GifSwiping!)";
    _bottomInstructionsLabel.numberOfLines = 1;
    _bottomInstructionsLabel.adjustsFontSizeToFitWidth = YES;
    _bottomInstructionsLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    if(IS_IPHONE_4_OR_LESS) {
        _bottomInstructionsLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - 20);
    }
    [self addSubview:_bottomInstructionsLabel];
}

- (void)setupSwipeToChoose {
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;
    __weak GSOnboardingInstructionsView *weakself = self;
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

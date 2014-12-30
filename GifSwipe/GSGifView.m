//
//  GSGifView.m
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import "GSGifView.h"
#import "UIImage+animatedGIF.h"
#import <BlurImageProcessor/ALDBlurImageProcessor.h>
#import "UIView+MDCBorderedLabel.h"

static CGFloat const MDCSwipeToChooseViewHorizontalPadding = 20.f;
static CGFloat const MDCSwipeToChooseViewTopPadding = 35.f;
static CGFloat const MDCSwipeToChooseViewLabelWidth = 65.f;

@interface GSGifView ()

@property (nonatomic, strong) MDCSwipeToChooseViewOptions *options;

@end

@implementation GSGifView


- (instancetype)initWithFrame:(CGRect)frame
                          gif:(GSGif *)gsgif
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame];
    if (self) {
        _options = options ? options : [MDCSwipeToChooseViewOptions new];

        self.gif = gsgif;
        [self setupView];
        [self constructImageView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self constructMainView];
            [self constructLikedView];
            [self constructNopeImageView];
            [self setupSwipeToChoose];
        });
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 2.f;
    self.layer.borderColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1].CGColor;
}

- (void)constructImageView {
    CGFloat bottomHeight = 35.f;
    CGRect imageFrame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.bounds),
                                  CGRectGetHeight(self.bounds) - bottomHeight);
 
    _backgroundImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    if(self.gif.gifPreviewLink != nil){
        UIImage *backgroundImage =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.gif.gifPreviewLink]]];
        _backgroundImageView.image = backgroundImage;
        ALDBlurImageProcessor *avatarBlur = [[ALDBlurImageProcessor alloc] initWithImage:backgroundImage];
        [avatarBlur asyncBlurWithRadius: 5
                             iterations:5
                           successBlock:^(UIImage *blurredImage) {
                               self.gif.blurredBackroundImage = blurredImage;
                               _backgroundImageView.image = blurredImage;
                           }
                             errorBlock:^(NSNumber *errorCode)  {
                                 NSLog( @"Error code: %d", [errorCode intValue] );
                             }];
        [self addSubview:_backgroundImageView];
    }
  
    
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.gif.gifLink]]];
    
    _gifImageView = [[FLAnimatedImageView alloc] initWithFrame:imageFrame];
    _gifImageView.clipsToBounds = YES;
    _gifImageView.contentMode = UIViewContentModeScaleAspectFit;
    _gifImageView.animatedImage = gifImage;
    [self addSubview:_gifImageView];
}

- (void)constructMainView {
    CGFloat bottomHeight = 35.f;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    bottomHeight);
    _mainView = [[UIView alloc] initWithFrame:bottomFrame];
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.clipsToBounds = YES;
    _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_mainView];
    
    CGRect frame = CGRectMake(2,
                              2,
                              floorf(CGRectGetWidth(_mainView.frame) - 4),
                              CGRectGetHeight(_mainView.frame) - 6);
    _captionLabel = [[UILabel alloc] initWithFrame:frame];
    _captionLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:20];
    _captionLabel.adjustsFontSizeToFitWidth = YES;
    _captionLabel.numberOfLines = 1;
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    _captionLabel.text = self.gif.caption;
    [_mainView addSubview:_captionLabel];
}

- (void)constructLikedView {

    CGRect frame = CGRectMake(MDCSwipeToChooseViewHorizontalPadding,
                              MDCSwipeToChooseViewTopPadding,
                              CGRectGetMidX(self.backgroundImageView.bounds),
                              MDCSwipeToChooseViewLabelWidth);
    self.likedView = [[UIView alloc] initWithFrame:frame];
    [self.likedView constructBorderedLabelWithText:self.options.likedText
                                             color:self.options.likedColor
                                             angle:self.options.likedRotationAngle];
    self.likedView.alpha = 0.f;
    [self addSubview:self.likedView];
}

- (void)constructNopeImageView {
    CGFloat width = CGRectGetMidX(self.backgroundImageView.bounds);
    CGFloat xOrigin = CGRectGetMaxX(self.backgroundImageView.bounds) - width - MDCSwipeToChooseViewHorizontalPadding;
    self.nopeView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,
                                                                  MDCSwipeToChooseViewTopPadding,
                                                                  width,
                                                                  MDCSwipeToChooseViewLabelWidth)];
    [self.nopeView constructBorderedLabelWithText:self.options.nopeText
                                            color:self.options.nopeColor
                                            angle:self.options.nopeRotationAngle];
    self.nopeView.alpha = 0.f;
    [self addSubview:self.nopeView];
}

- (void)setupSwipeToChoose {
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;
    
    __block UIView *likedImageView = self.likedView;
    __block UIView *nopeImageView = self.nopeView;
    __weak GSGifView *weakself = self;
    options.onPan = ^(MDCPanState *state) {
        if (state.direction == MDCSwipeDirectionNone) {
            likedImageView.alpha = 0.f;
            nopeImageView.alpha = 0.f;
        } else if (state.direction == MDCSwipeDirectionLeft) {
            likedImageView.alpha = 0.f;
            nopeImageView.alpha = state.thresholdRatio;
        } else if (state.direction == MDCSwipeDirectionRight) {
            likedImageView.alpha = state.thresholdRatio;
            nopeImageView.alpha = 0.f;
        }
        
        if (weakself.options.onPan) {
            weakself.options.onPan(state);
        }
    };
    
    [self mdc_swipeToChooseSetup:options];
}


@end

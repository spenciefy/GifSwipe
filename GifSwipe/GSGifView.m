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
        });
        [self setupSwipeToChoose];
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
    UIImage *backgroundImage =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.gif.gifPreviewLink]]];
    _backgroundImageView.image = backgroundImage;
    ALDBlurImageProcessor *avatarBlur = [[ALDBlurImageProcessor alloc] initWithImage:backgroundImage];
    [avatarBlur asyncBlurWithRadius: 5
                         iterations:5
                       successBlock:^(UIImage *blurredImage) {
                           _backgroundImageView.image = blurredImage;
                       }
                         errorBlock:^(NSNumber *errorCode)  {
                             NSLog( @"Error code: %d", [errorCode intValue] );
                         }];
    [self addSubview:_backgroundImageView];
    
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

- (void)setupSwipeToChoose {
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;
    __weak GSGifView *weakself = self;
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

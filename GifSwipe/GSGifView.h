//
//  GSGifView.h
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSGif.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "FLAnimatedImage.h"

@class MDCSwipeToChooseViewOptions;

@interface GSGifView : UIView

@property (nonatomic, strong) GSGif *gif;

@property (nonatomic, strong) FLAnimatedImageView *gifImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UILabel *captionLabel;


- (instancetype)initWithFrame:(CGRect)frame
                       gif:(GSGif *)gsgif
                      options:(MDCSwipeToChooseViewOptions *)options;


@end

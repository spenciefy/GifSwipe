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

@property (nonatomic, strong) IBOutlet FLAnimatedImageView *gifImageView;
@property (nonatomic, strong) IBOutlet  UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UILabel *captionLabel;

@property (nonatomic, strong) UIView *likedView;
@property (nonatomic, strong) UIView *nopeView;


- (instancetype)initWithFrame:(CGRect)frame
                       gif:(GSGif *)gsgif
                      options:(MDCSwipeToChooseViewOptions *)options;


@end

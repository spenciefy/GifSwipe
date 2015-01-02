//
//  GSOnboardingWelcomeView.h
//  GifSwipe
//
//  Created by Spencer Yen on 1/2/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "FLAnimatedImage.h"

@class MDCSwipeToChooseViewOptions;

@interface GSOnboardingWelcomeView : UIView

@property (nonatomic, strong) IBOutlet FLAnimatedImageView *gifImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *captionLabel;
@property (nonatomic, strong) IBOutlet UILabel *bottomInstructionsLabel;

- (instancetype)initWithFrame:(CGRect)frame
                       options:(MDCSwipeToChooseViewOptions *)options;
@end

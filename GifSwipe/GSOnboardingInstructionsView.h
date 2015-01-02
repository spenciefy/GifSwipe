//
//  GSOnboardingInstructionsView.h
//  GifSwipe
//
//  Created by Spencer Yen on 1/2/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@class MDCSwipeToChooseViewOptions;

@interface GSOnboardingInstructionsView : UIView

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *swipeRightLabel;
@property (nonatomic, strong) IBOutlet UILabel *swipeLeftLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareLabel;
@property (nonatomic, strong) IBOutlet UILabel *likedLabel;
@property (nonatomic, strong) IBOutlet UIImageView *shareImageVidw;
@property (nonatomic, strong) IBOutlet UIImageView *likedImageView;
@property (nonatomic, strong) IBOutlet UILabel *bottomInstructionsLabel;


- (instancetype)initWithFrame:(CGRect)frame
                      options:(MDCSwipeToChooseViewOptions *)options;
@end


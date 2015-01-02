//
//  GSOnboardingInstructionsView.m
//  GifSwipe
//
//  Created by Spencer Yen on 1/2/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "GSOnboardingInstructionsView.h"

@interface GSOnboardingInstructionsView ()

@property (nonatomic, strong) MDCSwipeToChooseViewOptions *options;

@end

@implementation GSOnboardingInstructionsView

- (instancetype)initWithFrame:(CGRect)frame
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame];
    if (self) {
        _options = options ? options : [MDCSwipeToChooseViewOptions new];
        [self constructView];
        [self setupSwipeToChoose];

    }
    return self;
}

- (void)constructView {
    
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

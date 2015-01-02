//
//  GSMainViewController.h
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSGifView.h"
#import "FLAnimatedImage.h"
#import "GSOnboardingWelcomeView.h"
#import "GSOnboardingInstructionsView.h"

@interface GSMainViewController : UIViewController <MDCSwipeToChooseDelegate>

@property (nonatomic, strong) GSGifView *currentGifView;
@property (nonatomic, strong) GSGifView *frontGifView;
@property (nonatomic, strong) GSGifView *backGifView;

@property (nonatomic, strong) GSOnboardingInstructionsView *instructionsGifView;
@property (nonatomic, strong) GSOnboardingWelcomeView *welcomeGifView;


- (IBAction)shareAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareActionButton;


@end

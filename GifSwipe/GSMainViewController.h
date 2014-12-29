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

@interface GSMainViewController : UIViewController <MDCSwipeToChooseDelegate>

@property (nonatomic, strong) GSGif *currentGif;
@property (nonatomic, strong) GSGifView *frontGifView;
@property (nonatomic, strong) GSGifView *backGifView;
@property (nonatomic, strong) GSGifView *thirdGifView;

@end

//
//  GSPopOutView.h
//  GifSwipe
//
//  Created by Alex Yeh on 12/30/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSGif.h"

@interface GSPopOutView : UIView 

@property (strong, nonatomic) GSGif *gif;

- (void)loadGif;

@end

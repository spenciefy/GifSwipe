//
//  GSPopOutView.h
//  GifSwipe
//
//  Created by Alex Yeh on 12/30/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSGif.h"

typedef void (^GSPopOutViewActionBlock)();

@interface GSPopOutView : UIView 

@property (strong, nonatomic) GSGif *gif;

- (id)initWithFrame:(CGRect)frame gif:(GSGif *)gif;

@property (nonatomic, strong) GSPopOutViewActionBlock shareActionBlock;
@property (nonatomic, strong) GSPopOutViewActionBlock closeActionBlock;


@end

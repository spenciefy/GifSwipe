//
//  GSLoadingView.h
//  GifSwipe
//
//  Created by Alex Yeh on 12/29/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSLoadingView : UIView {
    NSString *gifName;
    NSString *gifText;
}

- (void)setGifName:(NSString *)name;
- (void)setGifText:(NSString *)text;

@end

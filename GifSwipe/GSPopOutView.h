//
//  GSPopOutView.h
//  GifSwipe
//
//  Created by Alex Yeh on 12/30/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSPopOutView : UIView {
    NSString *gifName;
    NSString *gifText;
}

- (void)setGifName:(NSString *)name;
- (void)setGifText:(NSString *)text;
@end

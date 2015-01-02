//
//  GSGifCollectionViewCell.m
//  GifSwipe
//
//  Created by Spencer Yen on 1/1/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "GSGifCollectionViewCell.h"

@implementation GSGifCollectionViewCell

- (id)initWithAnimatedImage:(FLAnimatedImage *)gifImage gif:(GSGif *)gif {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1].CGColor;
        
        FLAnimatedImageView *gifImageView = [[FLAnimatedImageView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        
        gifImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        gifImageView.clipsToBounds = YES;
        gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        gifImageView.animatedImage = gifImage;
        
        //set rest of views here
        self.backgroundImage.image = gif.blurredBackroundImage;
        
    }
    return self;

}

- (void)showDeleteView {
    if(self.deleteLabel.alpha == 0.0)
        [UIView animateWithDuration: 0.3 animations: ^ {
            self.deleteLabel.alpha = 1.0;
        }];
}


@end

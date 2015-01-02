//
//  GSGifCollectionViewCell.m
//  GifSwipe
//
//  Created by Spencer Yen on 1/1/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "GSGifCollectionViewCell.h"

@implementation GSGifCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1].CGColor;
        
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.backgroundImage.contentMode = UIViewContentModeScaleToFill;
        self.backgroundImage.clipsToBounds = YES;
        [self addSubview:self.backgroundImage];
        
        self.gifImageView = [[FLAnimatedImageView alloc] initWithFrame:self.frame];
        self.gifImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.gifImageView.clipsToBounds = YES;
        self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.gifImageView];
        
        self.deleteLabel = [[UILabel alloc] init];
        self.deleteLabel.frame = self.frame;
        self.deleteLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.deleteLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:70];
        self.deleteLabel.text = @"x";
        self.deleteLabel.textAlignment = NSTextAlignmentCenter;
        self.deleteLabel.textColor = [UIColor whiteColor];
        self.deleteLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:45/255.0 blue:15/255.0 alpha:0.45];
        self.deleteLabel.alpha = 0;
        [self addSubview: self.deleteLabel];

    }
    return self;
}

- (void)setGif:(GSGif *)gif {
    _gif = gif;
    self.backgroundImage.image = gif.blurredBackroundImage;
}

- (void)setGifImage:(FLAnimatedImage *)gifImage {
    _gifImage = gifImage;
    self.gifImageView.animatedImage = gifImage;
}

@end

//
//  GSGifCollectionViewCell.h
//  GifSwipe
//
//  Created by Spencer Yen on 1/1/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "GSGif.h"

@interface GSGifCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UILabel *deleteLabel;
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) FLAnimatedImageView *gifImageView;

@property (strong, nonatomic) GSGif *gif;
@property (strong, nonatomic) FLAnimatedImage *gifImage;


@end



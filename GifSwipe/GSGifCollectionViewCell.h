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
@property (strong, nonatomic) IBOutlet UILabel *deleteLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
- (id)initWithAnimatedImage:(FLAnimatedImage *)gifImage gif:(GSGif *)gif;

@end



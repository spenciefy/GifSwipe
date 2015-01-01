//
//  GSPopOutView.m
//  GifSwipe
//
//  Created by Alex Yeh on 12/30/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import "GSPopOutView.h"
#import "FLAnimatedImage.h"

@implementation GSPopOutView {
    FLAnimatedImageView *gifImageView;
    UILabel *caption;
    UIImageView *backgroundImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame gif:(GSGif *)gif {
    self = [super initWithFrame:frame];
    if (self) {
        self.gif = gif;
        
        backgroundImage = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        backgroundImage.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        backgroundImage.image = self.gif.blurredBackroundImage;
        [self addSubview: backgroundImage];
        
        NSURL *gifURL = [NSURL URLWithString:self.gif.gifLink];
        NSString *gifFileName = [gifURL lastPathComponent];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *gifFileLocation = [NSString stringWithFormat:@"%@/liked_gifs/%@",documentsDirectory, gifFileName];
        NSData *gifData = [NSData dataWithContentsOfFile:gifFileLocation];
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
        gifImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), self.frame.size.width, self.frame.size.height)];
        gifImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - 20);
        gifImageView.animatedImage = gifImage;
        gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview: gifImageView];
        
        caption = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        caption.center = CGPointMake(CGRectGetMidX(self.bounds), self.frame.size.height - 10);
        caption.layer.backgroundColor = [UIColor whiteColor].CGColor;
        caption.textAlignment = NSTextAlignmentCenter;
        caption.text = self.gif.caption;
        [self addSubview:caption];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1].CGColor;
    }
    return self;
}
    
- (void)shareTapped {
    if (self.shareActionBlock) {
        self.shareActionBlock();
    }
}

- (void)closeTapped:(id)sender {
    if (self.closeActionBlock) {
        self.closeActionBlock();
    }
}

@end

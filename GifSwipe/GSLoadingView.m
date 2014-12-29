//
//  GSLoadingView.m
//  GifSwipe
//
//  Created by Alex Yeh on 12/29/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import "GSLoadingView.h"
#import "FLAnimatedImage.h"

@implementation GSLoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *path=[[NSBundle mainBundle]pathForResource:gifName ofType:@"gif"];
        NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
        FLAnimatedImageView *loadingImageView;
        loadingImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), self.frame.size.width, self.frame.size.height)];
        loadingImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - 20);
        loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
        loadingImageView.animatedImage = gifImage;
        UILabel *loadingText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        loadingText.center = CGPointMake(CGRectGetMidX(self.bounds), self.frame.size.height - 10);
        loadingText.text = gifText;
        loadingText.layer.backgroundColor = [UIColor whiteColor].CGColor;
        loadingText.textAlignment = NSTextAlignmentCenter;
        [self addSubview:loadingText];
        [self addSubview: loadingImageView];
        [self.layer setCornerRadius: 15.0f];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

- (void)setGifName:(NSString *)name {
    gifName = name;
}

-(void)setGifText:(NSString *)text {
    gifText = text;
}

@end

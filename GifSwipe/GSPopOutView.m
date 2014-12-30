//
//  GSPopOutView.m
//  GifSwipe
//
//  Created by Alex Yeh on 12/30/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import "GSPopOutView.h"
#import "FLAnimatedImage.h"

@implementation GSPopOutView

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
        FLAnimatedImageView *gifImageView;
        gifImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), self.frame.size.width, self.frame.size.height)];
        gifImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - 20);
        gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        gifImageView.animatedImage = gifImage;
        UILabel *caption = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        caption.center = CGPointMake(CGRectGetMidX(self.bounds), self.frame.size.height - 10);
        caption.text = gifText;
        caption.layer.backgroundColor = [UIColor whiteColor].CGColor;
        caption.textAlignment = NSTextAlignmentCenter;
        [self addSubview:caption];
        [self addSubview: gifImageView];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1].CGColor;
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

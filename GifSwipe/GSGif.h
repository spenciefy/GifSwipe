//
//  GSGif.h
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GSGif : NSObject

@property (nonatomic, strong) NSString *gifLink;
@property (nonatomic, strong) NSString *gifPreviewLink;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *gifID;
@property (nonatomic, strong) UIImage *blurredBackroundImage;

- (instancetype)initWithLink:(NSString *)link previewLink:(NSString *)pLink caption:(NSString *)caption gifID:(NSString *)theID;

@end

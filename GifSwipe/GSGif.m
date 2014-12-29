//
//  GSGif.m
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import "GSGif.h"

@implementation GSGif

- (instancetype)initWithLink:(NSString *)link previewLink:(NSString *)pLink caption:(NSString *)caption gifID:(NSString *)theID {
    self = [super init];
    if (self) {
        self.gifLink = link;
        self.gifPreviewLink = pLink;
        self.caption = caption;
        self.gifID = theID;
    }
    return self;
}
@end

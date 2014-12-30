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

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.gifLink forKey:@"gifLink"];
    [encoder encodeObject:self.gifPreviewLink forKey:@"gifPreviewLink"];
    [encoder encodeObject:self.caption forKey:@"caption"];
    [encoder encodeObject:self.gifID forKey:@"gifID"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.gifLink = [decoder decodeObjectForKey:@"gifLink"];
    self.gifPreviewLink = [decoder decodeObjectForKey:@"gifPreviewLink"];
    self.caption = [decoder decodeObjectForKey:@"caption"];
    self.gifID = [decoder decodeObjectForKey:@"gifID"];
    
    return self;
}

@end

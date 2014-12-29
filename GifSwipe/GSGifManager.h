//
//  GSGifManager.h
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSGifManager : NSObject

+ (GSGifManager *)sharedInstance;

- (void)fetchGifsWithCompletionBlock:(void (^)(NSArray *gifs, NSError *error))completionBlock;

@end
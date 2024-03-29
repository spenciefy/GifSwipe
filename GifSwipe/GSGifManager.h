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

- (void)fetchGifsFrom:(NSString *)from limit:(NSString *)limit new:(BOOL)new withCompletionBlock:(void (^)(NSArray *gifs, NSArray *gifIDs, NSError *error))completionBlock;

- (void)startLoadingGifsInBackground;
    
@property (nonatomic, strong) NSMutableArray *addedGifIDs;
@property (nonatomic, strong) NSMutableArray *gifs;
@property (nonatomic, strong) NSMutableArray *displayedGifIDs;
@property (nonatomic, strong) NSMutableArray *likedGifs;
@property (nonatomic, strong) NSString *lastGifID;
@property (nonatomic, assign) int newGifIndex;
@property (nonatomic, assign) BOOL loadGifs;


@end
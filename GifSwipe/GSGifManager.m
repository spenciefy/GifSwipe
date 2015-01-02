//
//  GSGifManager.m
//  GifShake
//
//  Created by Spencer Yen on 12/28/14.
//  Copyright (c) 2014 Parameter Labs. All rights reserved.
//

#import "GSGifManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GSGif.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

//https://graph.facebook.com/v2.2/201636233240648/feed?access_token=679031018880162|p-4FAOxNNYD-AsdY7KNuTWLS88o
#define ACCESS_TOKEN @"679031018880162|p-4FAOxNNYD-AsdY7KNuTWLS88o"

@implementation GSGifManager

+ (GSGifManager *)sharedInstance {
    static GSGifManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GSGifManager alloc] init];
        _sharedInstance.addedGifIDs = [[NSMutableArray alloc] init];
        _sharedInstance.gifs = [[NSMutableArray alloc] init];
        _sharedInstance.displayedGifIDs = [[NSMutableArray alloc] init];
        _sharedInstance.newGifIndex = 0;
        _sharedInstance.loadGifs = NO;
        _sharedInstance.lastGifID = @"";
        _sharedInstance.likedGifs = [[NSMutableArray alloc] init];
    });
    return _sharedInstance;
}

- (void)fetchGifsFrom:(NSString *)from limit:(NSString *)limit new:(BOOL)new withCompletionBlock:(void (^)(NSArray *gifs, NSArray *gifIDs, NSError *error))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString *urlString;
        if(new) {
            //sketch, in this case from is the id of the previous gif id
            urlString = [NSString stringWithFormat:@"http://www.reddit.com/r/gifs/new/.json?after=%@&limit=%@", from, limit];
        } else {
            urlString = [NSString stringWithFormat:@"http://www.reddit.com/r/gifs/.json?count=%@&limit=%@", from, limit];
        }
        
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:5];
        
        [request setHTTPMethod: @"GET"];
        NSError *requestError;
#warning need to fix this weird completion block bug
        NSURLResponse *urlResponse = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        if(requestError) {
            NSLog(@"request error in reddit stuff %@", requestError);
            completionBlock(nil,nil,requestError);
        } else if(response){
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response
                                                                 options:kNilOptions
                                                                   error:&error];
            
            NSArray *posts = [[json objectForKey:@"data"] objectForKey:@"children"];
            //this is to keep track of gifs including those that aren't valid
            NSMutableArray *gifsIncludingNonGifs = [[NSMutableArray alloc] init];
            for(int i = 0; i < posts.count; i++) {
                GSGif *gif = [self gifForJSONPost:posts[i][@"data"]];
             //   if(((!new && ![self.displayedGifIDs containsObject:gif.gifID]) || new)) {
                    if(gif.gifLink) {
                        NSURL *gifURL = [NSURL URLWithString:gif.gifLink];
                        NSString *gifFileName = [gifURL lastPathComponent];
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSString *gifFileLocation = [documentsDirectory stringByAppendingPathComponent:gifFileName];
                        
                        NSURLRequest *gifURLRequest = [NSURLRequest requestWithURL:gifURL];
                        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:gifURLRequest];
                        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
                            NSData *gifData = [[NSData alloc] initWithData:data];
                            [gifData writeToFile:gifFileLocation atomically:YES];
                            gif.gifData = gifData;
                            
                            if(gif && ![self.addedGifIDs containsObject:gif.gifID]) {
                                [self.gifs addObject:gif];
                                [gifsIncludingNonGifs addObject:gif];
                                [self.addedGifIDs addObject:gif.gifID];
                                NSLog(@"added gif %@ data with: %@",gif.gifID, gifFileLocation);
                            }
                            if(new) {
                                if(i == posts.count-1) {
                                    self.lastGifID = gif.gifID;
                                    completionBlock(self.gifs,self.addedGifIDs, nil);
                                }
                            } else if (self.gifs.count >= 3) {
                                //this is definitely sketchy... the point of this is to quickly update ui once there are 5 gifs but continue loading the rest lol
                                static dispatch_once_t onceToken;
                                dispatch_once(&onceToken, ^{
                                    completionBlock(self.gifs,self.addedGifIDs, nil);
                                });
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"error in urlsession: %@ with location%@, giflink: %@", error.description, gifFileLocation, gif.gifLink);
                            completionBlock(nil,nil,error);
                        }];
                        [requestOperation start];
                    } else {
                        [gifsIncludingNonGifs addObject:gif];
                        if(i == posts.count-1) {
                            if(new){
                                self.lastGifID = gif.gifID;
                                NSError *error = [[NSError alloc]initWithDomain:@"Gif doesn't have .gif" code:999 userInfo:nil];
                                completionBlock(nil,nil,error);
                            }
                        }
                    }
             //   }
            }
        }
    });
}


- (void)startLoadingGifsInBackground{
    if(self.gifs.count < 10) {
        if (self.loadGifs) {
            if(self.lastGifID) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [self fetchGifsFrom:self.lastGifID limit:@"3" new:YES withCompletionBlock:^(NSArray *gifs, NSArray *gifIDs, NSError *error) {
                        if(!error) {
                            NSLog(@"loaded 1 gif, now gifs count %lu", (unsigned long)self.gifs.count);
                        } else {
                            NSLog(@"error in fetching 1: %@", error.description);
                        }
                        [self startLoadingGifsInBackground];
                        
                    }];
                });
            } else {
                NSAssert(self.lastGifID == nil,@"no last gif");
                NSLog(@"no last gif...");
            }
        }
    } else {
        NSLog(@"gifs count: %lu, enough so stop loading", (unsigned long)self.gifs.count);
        self.loadGifs = NO;
    }
}

- (GSGif *)gifForJSONPost:(NSDictionary *)jsonPost{
    NSString *url = jsonPost[@"url"];
   // NSString *urlWithoutV = [url stringByReplacingOccurrencesOfString:@".gifv" withString:@".gif"];
    
    NSString *caption = jsonPost[@"title"];
    if(!([caption hasPrefix:@"\""] && [caption hasSuffix:@"\""])){
        caption = [NSString stringWithFormat:@"\"%@\"", caption];
    }
    if([url rangeOfString:@".gif"].location != NSNotFound && [url rangeOfString:@".gifv"].location == NSNotFound) {
        NSString *previewLink = jsonPost[@"thumbnail"];
        if([previewLink isEqualToString:@"nsfw"] || [previewLink isEqualToString:@"default"]) {
            previewLink = nil;
        }
        GSGif *gif = [[GSGif alloc] initWithLink:url previewLink:previewLink caption:caption gifID:jsonPost[@"name"]];
        return gif;
    } else {
        GSGif *gif = [[GSGif alloc] initWithLink:nil previewLink:nil caption:@"Gif returned only for id" gifID:jsonPost[@"name"]];
        return gif;
    }
}

@end

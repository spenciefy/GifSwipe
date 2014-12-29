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
//https://graph.facebook.com/v2.2/201636233240648/feed?access_token=679031018880162|p-4FAOxNNYD-AsdY7KNuTWLS88o
#define ACCESS_TOKEN @"679031018880162|p-4FAOxNNYD-AsdY7KNuTWLS88o"
@implementation GSGifManager

+ (GSGifManager *)sharedInstance {
    static GSGifManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GSGifManager alloc] init];
        
    });
    return _sharedInstance;
}

- (void)fetchGifsWithCompletionBlock:(void (^)(NSArray *gifs, NSError *error))completionBlock {
    
    NSString *urlString = @"http://www.reddit.com/r/gifs/new/.json?count=1&limit=20";
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:5];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response
                                                         options:kNilOptions
                                                           error:&error];
    
    NSArray *posts = [[json objectForKey:@"data"] objectForKey:@"children"];
    NSMutableArray *gifs = [[NSMutableArray alloc] init];
    for(int i = 0; i < posts.count; i++) {
        GSGif *gif = [self gifForJSONPost:posts[i][@"data"]];
        if(gif) {
            [gifs addObject:gif];
        }
        if(i == posts.count - 1) {
            completionBlock(gifs, nil);
        }
    }
    
}

- (GSGif *)gifForJSONPost:(NSDictionary *)jsonPost{
    NSString *url = jsonPost[@"url"];
    NSString *urlWithoutV = [url stringByReplacingOccurrencesOfString:@".gifv" withString:@".gif"];
    
    NSString *caption = jsonPost[@"title"];
    if(!([caption hasPrefix:@"\""] && [caption hasSuffix:@"\""])){
        caption = [NSString stringWithFormat:@"\"%@\"", caption];
    }
    if(([urlWithoutV rangeOfString:@".gif"].location != NSNotFound) && ![jsonPost[@"thumbnail"] isEqualToString:@"nsfw"] && ![jsonPost[@"thumbnail"] isEqualToString:@"default"]) {
        GSGif *gif = [[GSGif alloc] initWithLink:urlWithoutV previewLink:jsonPost[@"thumbnail"] caption:caption gifID:jsonPost[@"name"]];
        return gif;
    } else {
        return nil;
    }
}

@end

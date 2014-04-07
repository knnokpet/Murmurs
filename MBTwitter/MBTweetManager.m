//
//  MBTweetManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetManager.h"
#import "MBTweet.h"

@interface MBTweetManager()

@property (nonatomic, readonly) NSMutableDictionary *tweets;

@end

@implementation MBTweetManager
#pragma mark -
#pragma mark Initialize
+ (MBTweetManager *)sharedInstance
{
    static MBTweetManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MBTweetManager alloc] initSharedInstance];
    });
    
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        _tweets = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -
#pragma mark 
- (MBTweet *)storedTweetForKey:(NSString *)key
{
    if (nil == key) {
        return nil;
    }
    
    MBTweet *storedTweet = [self.tweets objectForKey:key];
    return storedTweet;
}

- (void)storeTweet:(MBTweet *)tweet
{
    if (nil == tweet) {
        return;
    }
    
    NSString *key = tweet.tweetIDStr;
    [self.tweets setObject:tweet forKey:key];
}

@end

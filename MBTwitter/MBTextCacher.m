//
//  MBTextCacher.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/25.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import "MBTextCacher.h"

@interface MBTextCacher()

@property (nonatomic, readonly) NSCache *userNameCache;
@property (nonatomic, readonly) NSCache *tweetTextCache;

@end

@implementation MBTextCacher
#pragma mark -
#pragma mark Initialize
+ (MBTextCacher *)sharedInstance
{
    static MBTextCacher *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[self alloc] initSharedInstance];
    });
    
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        _userNameCache = [[NSCache alloc] init];
        _tweetTextCache = [[NSCache alloc] init];
        self.userNameCache.countLimit = 300;
        self.tweetTextCache.countLimit = 1000;
    }
    
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -
#pragma mark Instance Methods
- (NSAttributedString *)cachedUserNameWithUserIDStr:(NSString *)key
{
    return [self cachedTextInCache:self.userNameCache key:key];
}

- (NSAttributedString *)cachedTweetTextWithTweetIDStr:(NSString *)key
{
    return [self cachedTextInCache:self.tweetTextCache key:key];
}

- (NSAttributedString *)cachedTextInCache:(NSCache *)cache key:(NSString *)key
{
    if (!cache || !key || key.length == 0) {
        return nil;
    }
    
    return [cache objectForKey:key];
}

- (void)storeUserName:(NSAttributedString *)attriName key:(NSString *)key
{
    [self storeText:attriName toCache:self.userNameCache key:key];
}

- (void)storeTweetText:(NSAttributedString *)attText key:(NSString *)key
{
    [self storeText:attText toCache:self.tweetTextCache key:key];
}

- (void)storeText:(NSAttributedString *)attText toCache:(NSCache *)cache key:(NSString *)key
{
    if (!cache || !attText || !key || key.length == 0) {
        return ;
    }
    
    [cache setObject:attText forKey:key];
}

#pragma mark Clear
- (void)clearMemoryCache
{
    [self.tweetTextCache removeAllObjects];
}

@end

//
//  MBTweetManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetManager.h"
#import "MBTweet.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBPlace.h"

#define SAVE_TWEET_MAX 1000
#define SAVE_TWEET_PER 100

#define SAVE_TIMELINE_PATH @"Timeline"
#define SAVE_REPLY_PATH @"Reply"
#define SAVE_PATH @"tweet.dat"

@interface MBTweetManager()

@property (nonatomic, readonly) NSMutableDictionary *tweets;
@property (nonatomic, readonly) NSString *tweetDirectory;

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
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _tweetDirectory = [[paths lastObject] stringByAppendingPathComponent:@"Tweet"];
        [self createDirectories];
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
    if (nil == storedTweet) {
        return nil;
    }
    
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

#pragma mark -
#pragma mark 
- (NSString *)pathForIndex:(NSInteger)index directory:(NSString *)path
{
    NSString *indexKey = [NSString stringWithFormat:@"%X", index];
    return [path stringByAppendingPathComponent:indexKey];
}

- (NSString *)pathForCurrentAccount
{
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    NSString *accountDirectoryPath = [self.tweetDirectory stringByAppendingPathComponent:currentAccount.userID];
    return accountDirectoryPath;
}

- (void)createDirectories
{
    [self createDirectoryAtPath:self.tweetDirectory];
    NSArray *accounts = [MBAccountManager sharedInstance].accounts;
    for (MBAccount *account in accounts) {
        NSString *accountID = account.userID;
        NSString *accountDirectoryPath = [self.tweetDirectory stringByAppendingPathComponent:accountID];
        [self createDirectoryAtPath:accountDirectoryPath];
        
        NSString *timelinePath = [accountDirectoryPath stringByAppendingPathComponent:SAVE_TIMELINE_PATH];
        [self createDirectoryAtPath:timelinePath];
        [self createSubPathAtPath:timelinePath];
        
        NSString *replyPath = [accountDirectoryPath stringByAppendingPathComponent:SAVE_REPLY_PATH];
        [self createDirectoryAtPath:replyPath];
        [self createSubPathAtPath:replyPath];
        
    }
}

- (void)createSubPathAtPath:(NSString *)path
{
    for (NSInteger i = 0; i < 10; i ++) {
        NSString *subPath = [NSString stringWithFormat:@"%@/%X", path, i];
        [self createDirectoryAtPath:subPath];
    }
}

- (void)createDirectoryAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!isDirectory || !exists) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark -
- (void)saveTimeline:(NSArray *)tweets
{
    NSString *accountDirectoryPath = [self pathForCurrentAccount];
    NSString *timelinePath = [accountDirectoryPath stringByAppendingPathComponent:SAVE_TIMELINE_PATH];
    [self saveTweets:tweets atPath:timelinePath];
}

- (void)saveReply:(NSArray *)tweets
{
    NSString *accountDirectoryPath = [self pathForCurrentAccount];
    NSString *timelinePath = [accountDirectoryPath stringByAppendingPathComponent:SAVE_REPLY_PATH];
    [self saveTweets:tweets atPath:timelinePath];
}

- (void)saveTweets:(NSArray *)tweets atPath:(NSString *)path
{
    
    NSMutableArray *tweetsForSave = [NSMutableArray arrayWithCapacity:SAVE_TWEET_PER];
    
    NSInteger directoryIndex = 0;
    NSInteger savingMax = SAVE_TWEET_MAX;
    NSInteger tweetIndex = 1;
    for (NSString *tweetID in tweets) {
        MBTweet *tweet = [self storedTweetForKey:tweetID];
        [tweetsForSave addObject:tweet];
        
        if (0 == (tweetIndex % 100)) {
            NSString *saveDirPath = [self pathForIndex:directoryIndex directory:path];
            NSString *savePath = [saveDirPath stringByAppendingPathComponent:SAVE_PATH];
            
            BOOL success = [NSKeyedArchiver archiveRootObject:tweetsForSave toFile:savePath];
            
            if (YES == success) {
                NSLog(@"succeed save twets");
                [tweetsForSave removeAllObjects];
            } else {
                NSLog(@"failed save tweets");
                break;
            }
        }
        
        if (tweetIndex == savingMax) {
            break;
        }
        tweetIndex ++;
    }
}

- (NSArray *)savedTimelineAtIndex:(NSInteger)index
{
    NSString *accountDirectoryPath = [self pathForCurrentAccount];
    NSString *timelinePath = [accountDirectoryPath stringByAppendingPathComponent:SAVE_TIMELINE_PATH];
    return [self savedTweetsAtPath:timelinePath atIndex:index];
}

- (NSArray *)savedReplyAtIndex:(NSInteger)index
{
    NSString *accountDirectoryPath = [self pathForCurrentAccount];
    NSString *replyPath = [accountDirectoryPath stringByAppendingPathComponent:SAVE_REPLY_PATH];
    return [self savedTweetsAtPath:replyPath atIndex:index];
}

- (NSArray *)savedTweetsAtPath:(NSString *)path atIndex:(NSInteger)index
{
    if (0 > index || nil == path || 0 == path.length) {
        return nil;
    }
    
    NSString *saveDirpath = [self pathForIndex:index directory:path];
    NSString *savePath = [saveDirpath stringByAppendingPathComponent:@"tweet.dat"];
    NSArray *savedTweets = [NSKeyedUnarchiver unarchiveObjectWithFile:savePath];
    NSMutableArray *tweetIDs = [NSMutableArray arrayWithCapacity:200];
    for (MBTweet *savedTweet in savedTweets) {
        [self storeTweet:savedTweet];
        [tweetIDs addObject:savedTweet.tweetIDStr];
    }
    
    return tweetIDs;
}

#pragma mark -

- (void)deleteAllSavedTweets
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *currentAccountPath = [self pathForCurrentAccount];
    if ([fileManager fileExistsAtPath:currentAccountPath]) {
        if ([fileManager removeItemAtPath:currentAccountPath error:nil]) {
            [self createDirectories];
        }
    }
}

@end

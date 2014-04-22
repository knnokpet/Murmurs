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
        _tweetDirectory = [[paths lastObject] stringByAppendingPathComponent:@"tweet"];
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
        
        for (NSInteger i = 0; i < 10; i ++) {
            NSString *subPath = [NSString stringWithFormat:@"%@/%X", accountDirectoryPath, i];
            [self createDirectoryAtPath:subPath];
        }
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

- (void)save
{
    NSString *accountDirectoryPath = [self pathForCurrentAccount];
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
    NSArray *sortedArray = [[self.tweets allKeys] sortedArrayUsingDescriptors:@[sortDesc]];
    
    NSMutableArray *saveArray = [NSMutableArray array];
    
    NSInteger index = 0;
    NSInteger savingMax = 1000;
    NSInteger tweets = 1;
    for (NSString *key in sortedArray) {
        MBTweet *tweet = [self storedTweetForKey:key];
        [saveArray addObject:tweet];
        
        if (0 == (tweets % 100)) {
            NSString *saveDirPath = [self pathForIndex:index directory:accountDirectoryPath];
            NSString *savePath = [saveDirPath stringByAppendingPathComponent:@"tweet.dat"];
            
            BOOL success = [NSKeyedArchiver archiveRootObject:saveArray toFile:savePath];
            if (YES == success) {
                NSLog(@"successed  Saving Tweets");
            } else {
                NSLog(@"failed Saving Tweets");
                break;
            }
            [saveArray removeAllObjects];
        }
        
        if (tweets == savingMax) {
            break;
        }
        tweets++;
    } // 100 より少ない時に保存できないやん！
}

- (NSArray *)savedTweetsAtIndex:(NSInteger)index
{
    NSString *accountDirectoryPath = [self pathForCurrentAccount];
    NSString *saveDirpath = [self pathForIndex:index directory:accountDirectoryPath];
    NSString *savePath = [saveDirpath stringByAppendingPathComponent:@"tweet.dat"];
    NSArray *savedTweets = [NSKeyedUnarchiver unarchiveObjectWithFile:savePath];
    NSMutableArray *tweetIDs = [NSMutableArray arrayWithCapacity:200];
    for (MBTweet *savedTweet in savedTweets) {
        [self storeTweet:savedTweet];
        [tweetIDs addObject:savedTweet.tweetIDStr];
    }
    
    return tweetIDs;
}

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

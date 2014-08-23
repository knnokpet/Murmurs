//
//  MBTweetManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBTweet;
@class MBAccount;
@interface MBTweetManager : NSObject

+ (MBTweetManager *)sharedInstance;

- (MBTweet *)storedTweetForKey:(NSString *)key;
- (void)storeTweet:(MBTweet *)tweet;

- (void)saveTimeline:(NSArray *)tweets;
- (void)saveTimeline:(NSArray *)tweets withAccount:(MBAccount *)account;
- (void)saveReply:(NSArray *)tweets;
- (NSArray *)savedTimelineAtIndex:(NSInteger)index;
- (NSArray *)savedReplyAtIndex:(NSInteger)index;

- (void)deleteAllSavedTweets;
- (void)deleteAllSavedTweetsForAccount:(MBAccount *)account;
- (void)deleteAllSavedTweetsOfCurrentAccount;

@end

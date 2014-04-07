//
//  MBTweetManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBTweet;
@interface MBTweetManager : NSObject

+ (MBTweetManager *)sharedInstance;

- (MBTweet *)storedTweetForKey:(NSString *)key;
- (void)storeTweet:(MBTweet *)tweet;

@end

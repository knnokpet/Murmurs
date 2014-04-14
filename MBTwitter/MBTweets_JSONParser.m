//
//  MBTweets_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweets_JSONParser.h"

@implementation MBTweets_JSONParser

- (void)configure:(id)parsedObj
{
    NSMutableArray *gotTweets = [NSMutableArray arrayWithCapacity:200];
    for (NSDictionary *parsedTweet in (NSArray *)parsedObj) {
        MBTweet *tweet = [[MBTweet alloc] initWithDictionary:parsedTweet];
        [[MBTweetManager sharedInstance] storeTweet:tweet];
        [gotTweets addObject:tweet.tweetIDStr];
    }
    
    self.completion(gotTweets);
}

@end

//
//  MBSearchedTweets_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSearchedTweets_JSONParser.h"

@implementation MBSearchedTweets_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedDict = (NSDictionary *)parsedObj;
        NSArray *statuses = [parsedDict arrayForKey:@"statuses"];
        NSMutableArray *gotTweets = [NSMutableArray arrayWithCapacity:100];
        
        for (NSDictionary *parsedTweet in statuses) {
            MBTweet *tweet = [[MBTweet alloc] initWithDictionary:parsedTweet];
            [[MBTweetManager sharedInstance] storeTweet:tweet];
            [[MBUserManager sharedInstance] storeUser:tweet.tweetUser];
            [gotTweets addObject:tweet.tweetIDStr];
            if (tweet.tweetOfOriginInRetweet) {
                MBTweet *originTeet = tweet.tweetOfOriginInRetweet;
                [[MBTweetManager sharedInstance] storeTweet:originTeet];
                [[MBUserManager sharedInstance] storeUser:originTeet.tweetUser];
            }
        }
        
        self.completion(gotTweets);
    }
}

@end

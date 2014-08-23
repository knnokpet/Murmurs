//
//  MBTweet_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweet_JSONParser.h"

@implementation MBTweet_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        MBTweet *tweet = [[MBTweet alloc] initWithDictionary:(NSDictionary *)parsedObj];
        if (!tweet) {
            return;
        }
        
        [[MBTweetManager sharedInstance] storeTweet:tweet];
        [[MBUserManager sharedInstance] storeUser:tweet.tweetUser];
        NSArray *gotTweet = [NSArray arrayWithObject:tweet];
        self.completion(gotTweet);
    }
}

@end

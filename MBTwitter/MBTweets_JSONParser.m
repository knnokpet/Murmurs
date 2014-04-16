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
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *errorDict = (NSDictionary *)parsedObj;
        NSArray *errors = [errorDict arrayForKey:@"errors"];
        if (errors) {
            NSInteger code = [(NSDictionary *)[errors lastObject] integerForKey:@"code"];
            NSString *message = [(NSDictionary *)[errors lastObject] stringForKey:@"message"];
            NSError *error = [NSError errorWithDomain:message code:code userInfo:nil];
            [self failedParsing:error];
        }
    } else if ([parsedObj isKindOfClass:[NSArray class]]) {
        NSMutableArray *gotTweets = [NSMutableArray arrayWithCapacity:200];
        for (NSDictionary *parsedTweet in (NSArray *)parsedObj) {
            MBTweet *tweet = [[MBTweet alloc] initWithDictionary:parsedTweet];
            [[MBTweetManager sharedInstance] storeTweet:tweet];
            [gotTweets addObject:tweet.tweetIDStr];
        }
        
        self.completion(gotTweets);
    }
}

@end

//
//  MBDestroyTweet_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/10/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDestroyTweet_JSONParser.h"

@implementation MBDestroyTweet_JSONParser
- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        MBTweet *tweet = [[MBTweet alloc] initWithDictionary:(NSDictionary *)parsedObj];
        if (!tweet) {
            return;
        }
        
        NSArray *gotTweet = [NSArray arrayWithObject:tweet];
        self.completion(gotTweet);
    }
}

@end

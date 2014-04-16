//
//  MBJSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBJSONParser.h"

@implementation MBJSONParser
#pragma mark -
#pragma mark Initialize
- (id)initWithJSONData:(NSData *)jsonData completionHandler:(ParsingCompletion)completion
{
    self = [super init];
    if (self) {
        _jsonData = jsonData;
        _completion = completion;
    }
    
    return self;
}

- (void)startParsing
{
    NSError *parsingError = nil;
    id parsedObj = [NSJSONSerialization JSONObjectWithData:_jsonData options:0 error:&parsingError];
    
    if (parsingError) {
        [self failedParsing:parsingError];
    }
    
    if (nil == parsedObj) {
        NSError *error = [NSError errorWithDomain:@"parsing Error" code:0 userInfo:nil];
        [self failedParsing:error];
    }
    
    [self configure:parsedObj];

}

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
        
        _completion(gotTweets);
    }
}

- (void)failedParsing:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"parsing error = %@ code = %lu", error.localizedDescription, (unsigned long)error.code);
    });
}

@end

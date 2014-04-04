//
//  MBTwitterAPICenter.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBTwitterAPIHTTPConnecter.h"
#import "MBTwitterAPIRequestType.h"

#define HTTP_POST_METHOD @"POST"
#define HTTP_GET_METHOD @"GET"

#define DEFAULT_CONNECTION_TYPE @"https"
#define DEFAULT_API_DOMAIN @"api.twitter.com"
#define DEFAULT_API_VERSION @"1.1"
#define DEFAULT_API_EXTEND @"json"

#define TWEET_TEXT_LENGTH_MINIMUM 1
#define TWEET_TEXT_LENGTH_MAX 140

@interface MBTwitterAPICenter : NSObject < MBTwitterAPIHTTPConnecterDelegate >

@property (nonatomic) NSMutableDictionary *connections;

- (NSString *)sendRequestMethod:(NSString *)method resource:(NSString *)resource parameters:(NSDictionary *)parameters requestType:(MBRequestType)requestType responseType:(MBResponseType)responseType;
- (void)parseJSONData:(NSData *)jsonData responseType:(MBResponseType)responseType;

#pragma mark -
#pragma mark API Methods
- (NSString *)getBackHomeTimeLineMaxID:(unsigned long)max;
- (NSString *)getForwardHomeTimeLineSinceID:(unsigned long)since maxID:(unsigned long)max;
- (NSString *)getHomeTimeLineSinceID:(unsigned long)since maxID:(unsigned long)max;

- (NSString *)postTweet:(NSString *)tweetText;

@end

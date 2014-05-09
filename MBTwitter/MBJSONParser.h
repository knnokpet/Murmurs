//
//  MBJSONParser.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBTweetManager.h"
#import "MBTweet.h"
#import "MBUserManager.h"
#import "MBUser.h"

#import "NSDictionary+Objects.h"

typedef void (^ParsingCompletion)(NSArray *parsedObjects);
typedef void (^ParsingCompletionWithCursor)(NSArray *parsedObjects, NSNumber *nextCursor, NSNumber *previousCursor);

@interface MBJSONParser : NSObject

@property (nonatomic, readonly) NSData *jsonData;
@property (nonatomic, readonly) ParsingCompletion completion;
@property (nonatomic, readonly) ParsingCompletionWithCursor completionWithCursor;

- (id)initWithJSONData:(NSData *)jsonData completionHandler:(ParsingCompletion)completion;
- (id)initWithJSONData:(NSData *)jsonData completionHandlerWithCursor:(ParsingCompletionWithCursor)completion;

- (void)startParsing;
- (void)configure:(id)parsedObj;
- (void)failedParsing:(NSError *)error;

@end

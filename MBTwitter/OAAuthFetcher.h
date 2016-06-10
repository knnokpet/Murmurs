//
//  OAAuthFetcher.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAMutableRequest.h"

typedef void (^CompletionHandler)(NSData *data, NSHTTPURLResponse *response);
typedef void (^FailedHandler)(NSHTTPURLResponse *response);

@interface OAAuthFetcher : NSObject

@property (nonatomic, readonly) OAMutableRequest *request;
@property (nonatomic, readonly) CompletionHandler completionHandler;
@property (nonatomic, readonly) FailedHandler failedHandler;

- (id)initWithRequest:(OAMutableRequest *)request completionHandler:(CompletionHandler)cHandler failedHandler:(FailedHandler)fHandler;
+ (void)fetchWithRequest:(OAMutableRequest *)request completionHandler:(CompletionHandler)cHandler failedHandler:(FailedHandler)fHandler;

- (void)cancel;

@end

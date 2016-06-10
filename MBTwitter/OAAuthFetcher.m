//
//  OAAuthFetcher.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "OAAuthFetcher.h"

@interface OAAuthFetcher() <NSURLSessionDelegate>

@property (nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation OAAuthFetcher

- (id)initWithRequest:(OAMutableRequest *)request completionHandler:(CompletionHandler)cHandler failedHandler:(FailedHandler)fHandler
{
    self = [super init];
    if (self) {
        _request = request;
        _completionHandler = cHandler;
        _failedHandler = fHandler;
    }
    
    return self;
}

+ (void)fetchWithRequest:(OAMutableRequest *)request completionHandler:(CompletionHandler)cHandler failedHandler:(FailedHandler)fHandler {
    [request prepareOAuthRequest];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@, %@, %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
            fHandler((NSHTTPURLResponse *)response);
        } else {
            cHandler(data, (NSHTTPURLResponse *)response);
        }
    }];
    [dataTask resume];
}

#pragma mark -

- (void)cancel
{
    [self.dataTask cancel];
}

@end

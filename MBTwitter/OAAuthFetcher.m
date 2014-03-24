//
//  OAAuthFetcher.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "OAAuthFetcher.h"

@interface OAAuthFetcher() < NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSMutableData *connectionData;
@property (nonatomic) NSURLResponse *response;

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

#pragma mark -
- (void)start
{
    [self.request prepareRequest];
    
    if (self.connection) {
        self.connection = nil;
    }
    
    self.connectionData = [NSMutableData data];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
}

- (void)cancel
{
    if (self.connection) {
        [self.connection cancel];
        self.connection = nil;
    }
}

#pragma mark - 
#pragma mark NSURLConnection Delegate Method
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    if (self.response) {
        self.response = nil;
    }
    
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.failedHandler((NSHTTPURLResponse *)self.response);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.completionHandler(self.connectionData, (NSHTTPURLResponse *)self.response);
}

@end

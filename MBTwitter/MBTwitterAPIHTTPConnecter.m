//
//  MBTwitterAPIHTTPConnecter.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTwitterAPIHTTPConnecter.h"
#import "NSString+UUID.h"

@interface MBTwitterAPIHTTPConnecter() <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
{
    MBRequestType _requestType;
    MBResponseType _responseType;
}

@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSMutableData *connectionData;
@property (nonatomic) NSURLResponse *response;

@end

@implementation MBTwitterAPIHTTPConnecter

#pragma mark -
#pragma mark Initialize
- (id)initWithRequest:(NSURLRequest *)urlRequest requestType:(MBRequestType)requestType responseType:(MBResponseType)responseType
{
    self = [super init];
    if (self) {
        _request = urlRequest;
        _requestType = requestType;
        _responseType = responseType;
        _identifier = [NSString stringWithNewUUID];
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessor
- (MBRequestType)requestType
{
    return _requestType;
}

- (MBResponseType)responseType
{
    return _responseType;
}

#pragma mark -
#pragma mark Connection
- (void)start
{
    if (self.connection) {
        self.connection = nil;
    }
    
    self.connectionData = [NSMutableData data];
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

#pragma mark Connection Delegate
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(failedConnecter:error:responseType:)]) {
            [_delegate failedConnecter:self error:error responseType:self.responseType];
        }
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(finishedConnecter:data:responseType:)]) {
            [_delegate finishedConnecter:self data:self.connectionData responseType:self.responseType];
        }
    });
}

@end

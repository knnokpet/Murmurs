//
//  MBTwitterAPIHTTPConnecter.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTwitterAPIHTTPConnecter.h"
#import "NSString+UUID.h"

@interface MBTwitterAPIHTTPConnecter()
{
    MBRequestType _requestType;
    MBResponseType _responseType;
}

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
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(failedConnecter:error:responseType:)]) {
                    [_delegate failedConnecter:self error:error responseType:self.responseType];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(finishedConnecter:data:responseType:)]) {
                    [_delegate finishedConnecter:self data:data responseType:self.responseType];
                }
            });
        }
    }];
    
    [dataTask resume];
}

@end

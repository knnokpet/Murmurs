//
//  MBTwitterAccesser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTwitterAccesser.h"
#import "OAAccessibility.h"

#define REQUEST_TOKEN_URL @"https://api.twitter.com/oauth/request_token"
#define ACCESS_TOKEN_URL @"https://api.twitter.com/oauth/access_token"
#define AUTHORIZE_URL @"https://api.twitter.com/oauth/authenticate"

typedef void (^CompletionHandler)(NSMutableData *, NSHTTPURLResponse *);
typedef void (^FailedHandler)(NSHTTPURLResponse *);

@interface MBTwitterAccesser()

@property (nonatomic) OAConsumer *consumer;
@property (nonatomic) OAToken *requestToken;
@property (nonatomic) OAToken *accessToken;

@end

@implementation MBTwitterAccesser

#pragma mark -
#pragma mark Setter Getter
- (OAConsumer *)consumer
{
    if (_consumer) {
        return _consumer;
    }
    
    if (_consumerKey.length == 0 || _consumerSecret.length == 0) {
        NSLog(@"Please set consumer key & secret");
    }
    
    _consumer = [[OAConsumer alloc] initWithKey:self.consumerKey secret:self.consumerSecret];
    return _consumer;
}

- (void)setConsumerKey:(NSString *)consumerKey
{
    _consumerKey = consumerKey;
}

- (void)setConsumerSecret:(NSString *)consumerSecret
{
    _consumerSecret = consumerSecret;
}

#pragma mark -

- (BOOL)isAuthorized
{
    if (_accessToken.key && _accessToken.secret) {
        return YES;
    }
    
    _accessToken = [[OAToken alloc] initWithKey:nil secret:nil];
    return NO;
}

- (NSURLRequest *)authorizeURLRequest
{
    if (self.requestToken.key == nil || self.requestToken.secret == nil) {
        return nil;
    }
    
    NSURL *authorizeURL = [NSURL URLWithString:AUTHORIZE_URL];
    OAMutableRequest *authorizeURLRequest = [[OAMutableRequest alloc] initWithURL:authorizeURL consumer:nil token:self.requestToken realm:nil signatureProvider:nil];
    
    OARequestparameter *authorizeParameter = [OARequestparameter requestParameterWithName:@"oauth_token" value:self.requestToken.key];
    [authorizeURLRequest setParameters:[NSArray arrayWithObject:authorizeParameter]];
    return authorizeURLRequest;
}

#pragma mark -
#pragma mark SendRequest
- (void)requestRequestToken
{
    NSURL *url = [NSURL URLWithString:REQUEST_TOKEN_URL];

    [self sendRequestURL:url token:nil completionHandler:^(NSMutableData *data, NSHTTPURLResponse *response){
        NSUInteger status = [response statusCode];

        if (!(status >= 200 && status < 300) || !data) {
            NSLog(@"response ");
            NSDictionary *responseDic = [response allHeaderFields];
            [responseDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSLog(@"%@ = %@", key, obj);
            }];
            return;
        }
        
        
        NSLog(@"Get Request Token !");
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!dataString) {
            return;
        }
        
        OAToken *requestToken = [[OAToken alloc] initWithHTTPResponse:dataString];
        self.requestToken = requestToken;
        if ([_delegate respondsToSelector:@selector(getRequestTokenTwitterAccesser:)]) {
            [_delegate getRequestTokenTwitterAccesser:self];
        }
        
    } failedHandler:^(NSHTTPURLResponse *response){
        
        NSLog(@"Getting Request Token Error");
        
        NSUInteger status = [response statusCode];
        if (status >= 400 && status < 500) {
            NSLog(@"Client Error");
        } else if (status >= 500 && status < 600) {
            NSLog(@"Server Error");
        }
    }];
}

- (void)requestAccessToken
{
    NSURL *url = [NSURL URLWithString:ACCESS_TOKEN_URL];
    [self sendRequestURL:url token:nil completionHandler:^(NSMutableData *data, NSHTTPURLResponse *response){
        NSUInteger status = [response statusCode];
        if (!(status < 200 && status > 300) || !data) {
            return;
        }
        
        
        NSLog(@"Get Access Token !");
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!dataString) {
            return;
        }
        
        [self storeMyAccountFromHTTPBody:dataString];
        
        OAToken *accessToken = [[OAToken alloc] initWithHTTPResponse:dataString];
        self.accessToken = accessToken;
        
    } failedHandler:^(NSHTTPURLResponse *response){
        
        NSLog(@"Getting Request Token Error");
        
        NSUInteger status = [response statusCode];
        if (status >= 400 && status < 500) {
            NSLog(@"Client Error");
        } else if (status >= 500 && status < 600) {
            NSLog(@"Server Error");
        }
    }];
}

- (void)sendRequestURL:(NSURL *)url token:(OAToken *)token completionHandler:(CompletionHandler)completion failedHandler:(FailedHandler)failed
{
    if (self.pin.length > 0) {
        token.pin = self.pin;
    }
    
    OAMutableRequest *request = [[OAMutableRequest alloc] initWithURL:url consumer:self.consumer token:token realm:nil signatureProvider:nil];
    if (!request) {
        return;
    }
    [request setHTTPMethod:@"POST"];
    
    // for returning PIN
    OARequestparameter *callbackParameter = [OARequestparameter requestParameterWithName:@"oauth_callback" value:@"http://192.168.11.0/callback"];
    NSMutableArray *addingParameters = [NSMutableArray arrayWithArray:[request parameters]];
    //[addingParameters addObject:callbackParameter];
    [request setParameters:addingParameters];
    
    OAAuthFetcher *fetcher = [[OAAuthFetcher alloc] initWithRequest:request completionHandler:completion failedHandler:failed];
    [fetcher start];
}

#pragma mark -
#pragma mark
- (void)storeMyAccountFromHTTPBody:(NSString *)httpBody
{
    if (!httpBody) {
        return;
    }
    
    NSArray *nameValuePairs = [httpBody componentsSeparatedByString:@"&"];
    for (NSString *nameValuePair in nameValuePairs) {
        NSArray *keyAndValue = [nameValuePair componentsSeparatedByString:@"="];
        NSString *key = [keyAndValue objectAtIndex:0];
        NSString *value = [ keyAndValue objectAtIndex:1];
        
    }
}

@end

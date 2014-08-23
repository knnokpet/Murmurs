//
//  MBTwitterAccesser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTwitterAccesser.h"
#import "MBAccountManager.h"

#import "MBTwitterConsumer.h"
#import "OAAccessibility.h"
#import <Social/Social.h>

// URL
#define REQUEST_TOKEN_URL @"https://api.twitter.com/oauth/request_token"
#define ACCESS_TOKEN_URL @"https://api.twitter.com/oauth/access_token"
#define AUTHORIZE_URL @"https://api.twitter.com/oauth/authorize"

//
#define PARAMETER_KEY_OAUTH_TOKEN @"oauth_token"
#define PARAMETER_KEY_OAUTH_CALLBACK @"oauth_callback"
#define PARAMETER_KEY_X_AUTH_MODE @"x_auth_mode"
#define PARAMETER_KEY_X_REVERSE_AUTH_TARGET @"x_reverse_auth_target"

#define PARAMETER_VALUE_OOB @"oob"
#define PARAMETER_VALUE_REVERSE_AUTH @"reverse_auth"
#define PARAMETER_VALUE_X_REVERSE_AUTH_PARAMETERS @"x_reverse_auth_parameters"

typedef void (^CompletionHandler)(NSMutableData *, NSHTTPURLResponse *);
typedef void (^FailedHandler)(NSHTTPURLResponse *);

@interface MBTwitterAccesser()

@property (nonatomic) OAConsumer *consumer;
@property (nonatomic) OAToken *requestToken;
@property (nonatomic) OAToken *accessToken;

@end

@implementation MBTwitterAccesser
#pragma mark -
#pragma mark Initialize
- (id)init
{
    self = [super init];
    if (self) {
        [self setConsumerKey:CONSUMER_KEY];
        [self setConsumerSecret:CONSUMER_SECRET];
    }
    
    return self;
}

- (id)initWithAccessToken:(OAToken *)accessToken
{
    self = [super init];
    if (self) {
        
        if (!accessToken) {
            _accessToken = [[OAToken alloc] initWithKey:nil secret:nil];
        }
        _accessToken = accessToken;
    }
    
    return self;
}

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

- (void)setPin:(NSString *)pin
{
    _pin = pin;
    
    _requestToken.pin = pin;
    _accessToken.pin = pin;
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
    
    OAParameter* authorizeParameter = [OAParameter requestParameterWithName:PARAMETER_KEY_OAUTH_TOKEN value:self.requestToken.key];
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
        if ([_delegate respondsToSelector:@selector(gotRequestTokenTwitterAccesser:)]) {
            [_delegate gotRequestTokenTwitterAccesser:self];
        }
        
    } failedHandler:^(NSHTTPURLResponse *response){
        
        NSLog(@"Getting Request Token Error");
        
        NSUInteger status = [response statusCode];
        NSLog(@"status = %lu", (unsigned long)status);
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
    
    [self sendRequestURL:url token:_requestToken completionHandler:^(NSMutableData *data, NSHTTPURLResponse *response){
        NSUInteger status = [response statusCode];
        if (!(status >= 200 && status < 300) || !data) {
            NSLog(@"response ");
            NSDictionary *responseDic = [response allHeaderFields];
            [responseDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSLog(@"%@ = %@", key, obj);
            }];
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
        
        NSLog(@"Getting Access Token Error");
        
        NSUInteger status = [response statusCode];
        NSLog(@"status = %lu", (unsigned long)status);
        if (status >= 400 && status < 500) {
            NSLog(@"Client Error");
        } else if (status >= 500 && status < 600) {
            NSLog(@"Server Error");
        }
    }];
}

- (void)requestReverseRequestTokenWithAccount:(ACAccount *)account
{
    if (!account) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:REQUEST_TOKEN_URL];
    
    OAParameter *param = [OAParameter requestParameterWithName:PARAMETER_KEY_X_AUTH_MODE value:PARAMETER_VALUE_REVERSE_AUTH];
    NSArray *parameters = [NSArray arrayWithObject:param];
    
    [self sendRequestURL:url token:nil completionHandler:^ (NSMutableData *data, NSHTTPURLResponse *response) {
        NSInteger status = [response statusCode];
        
        if (!(status >= 200 && status < 300) || !data) {
            NSLog(@"response Error");
            return;
        }
        
        NSLog(@"Get Reverse Token!");
        
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!dataString) {
            return;
        }
        
        [self requestReverseAccessTokenWithAccount:account data:dataString];
        
    }failedHandler:^(NSHTTPURLResponse *response) {
        NSLog(@"Getting Reverse Token Error");
        
    }parameter:parameters];
}

- (void)requestReverseAccessTokenWithAccount:(ACAccount *)account data:(NSString *)data
{
    NSDictionary *parameters = @{PARAMETER_KEY_X_REVERSE_AUTH_TARGET: self.consumerKey, PARAMETER_VALUE_X_REVERSE_AUTH_PARAMETERS: data};
    
    NSURL *url = [NSURL URLWithString:ACCESS_TOKEN_URL];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:parameters];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSInteger status = [urlResponse statusCode];
        
        if (!(status >= 200 && status < 300) || !data) {
            NSLog(@"response Error");
            return;
        }
        
        NSLog(@"Get Reverse Access Token");
        
        NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if (!dataString) {
            return;
        }
        
        [self storeMyAccountFromHTTPBody:dataString];
        
    }];
    
    
}

- (void)sendRequestURL:(NSURL *)url token:(OAToken *)token completionHandler:(CompletionHandler)completion failedHandler:(FailedHandler)failed
{
    // for returning PIN
    OAParameter *callbackParameter = [OAParameter requestParameterWithName:@"oauth_callback" value:@"oob"];
    NSArray *parameters = [NSArray arrayWithObject:callbackParameter];
    
    [self sendRequestURL:url token:token completionHandler:completion failedHandler:failed parameter:parameters];
}

- (void)sendRequestURL:(NSURL *)url token:(OAToken *)token completionHandler:(CompletionHandler)completion failedHandler:(FailedHandler)failed parameter:(NSArray *)parameter
{
    if (self.pin.length > 0) {
        token.pin = self.pin;// setPin でセットしてるからいらないけど。
    }
    
    OAMutableRequest *request = [[OAMutableRequest alloc] initWithURL:url consumer:self.consumer token:token realm:nil signatureProvider:nil];
    if (!request) {
        return;
    }
    [request setHTTPMethod:@"POST"];
    
    NSMutableArray *addingParameters = [NSMutableArray arrayWithArray:[request parameters]];
    for (OAParameter *param in parameter) {
        [addingParameters addObject:param];
    }
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
    
    NSMutableDictionary *myAccountData = [NSMutableDictionary dictionary];
    
    NSString *userToken;
    NSString *userSecret;
    NSString *userID;
    NSString *userScreenName;
    
    NSArray *nameValuePairs = [httpBody componentsSeparatedByString:@"&"];
    for (NSString *nameValuePair in nameValuePairs) {
        NSArray *keyAndValue = [nameValuePair componentsSeparatedByString:@"="];
        NSString *key = [keyAndValue objectAtIndex:0];
        NSString *value = [keyAndValue objectAtIndex:1];
        
        if (YES == [key isEqualToString:@"oauth_token"]) {
            userToken = value;
        } else if (YES == [key isEqualToString:@"oauth_token_secret"]) {
            userSecret = value;
        } else if (YES == [key isEqualToString:@"user_id"]) {
            userID = value;
        } else if (YES == [key isEqualToString:@"screen_name"]) {
            userScreenName = value;
        }
        
        [myAccountData setObject:value forKey:key];
    }
    
    NSLog(@"token = %@, secret = %@, ID = %@, name = %@", userToken, userSecret, userID, userScreenName);
    
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    [accountManager saveMyAccountWith:myAccountData];
    
    if ([_delegate respondsToSelector:@selector(gotAccessTokenTwitterAccesser:)]) {
        [_delegate gotAccessTokenTwitterAccesser:self];
    }
}

@end

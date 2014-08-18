//
//  OAToken.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "OAToken.h"

@implementation OAToken

- (id)init
{
    self = [super init];
    if (self) {
        _key = @"";
        _secret = @"";
    }
    
    return self;
}

- (id)initWithKey:(NSString *)key secret:(NSString *)secret
{
    self = [super init];
    if (self) {
        _key = key;
        _secret = secret;
    }
    
    return self;
}

- (id)initWithHTTPResponse:(NSString *)body
{
    self = [super init];
    if (self) {
        NSArray *parameterPairs = [body componentsSeparatedByString:@"&"];
        
        for (NSString *pair in parameterPairs) {
            NSArray *parameters = [pair componentsSeparatedByString:@"="];
            NSString *httpKey = [parameters objectAtIndex:0];
            NSString *httpValue = [parameters objectAtIndex:1];
            if ([httpKey isEqualToString:@"oauth_token"]) {
                _key = httpValue;
            } else if ([httpKey isEqualToString:@"oauth_token_secret"]) {
                _secret = httpValue;
            } else if ([httpKey isEqualToString:@"oauth_verifier"]) {
                _pin = httpValue;
            }
        }
    }
    
    return self;
}

@end

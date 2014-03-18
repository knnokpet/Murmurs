//
//  OAConsumer.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "OAConsumer.h"

@implementation OAConsumer

- (id)initWithKey:(NSString *)key secret:(NSString *)secret
{
    self = [super init];
    if (self) {
        _key = key;
        _secret = secret;
    }
    
    return self;
}

@end

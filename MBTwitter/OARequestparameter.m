//
//  OARequestparameter.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "OARequestparameter.h"

@implementation OARequestparameter

+ (id)requestParameterWithName:(NSString *)name value:(NSString *)value
{
    return [[OARequestparameter alloc] initWithName:name value:value];
}

- (id)initWithName:(NSString *)name value:(NSString *)value
{
    self = [super init];
    if (self) {
        _name = name;
        _value = value;
    }
    
    return self;
}

#pragma mark -
#pragma mark  Public
- (NSString *)encodedNameValuePair
{
    return [NSString stringWithFormat:@"%@=%@", [self encodedName], [self encodedValue]];
}

#pragma mark Private
- (NSString *)encodedName
{
    return [self encodedString:self.name];
}

- (NSString *)encodedValue
{
    return [self encodedString:self.value];
}

- (NSString *)encodedString:(NSString *)string
{
    //return [string encodedString];
    
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, CFSTR("!*'\"();:@&=+$,/?#[]%<>{} "), kCFStringEncodingUTF8);
    return result;
}

@end

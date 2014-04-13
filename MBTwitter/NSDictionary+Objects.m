//
//  NSDictionary+Objects.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "NSDictionary+Objects.h"

@implementation NSDictionary (Objects)

- (NSString *)stringForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        return (NSString *)obj;
    } else {
        return nil;
    }
}

- (BOOL)boolForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:(id)[NSNull null]]) {
        return NO;
    } else {
        return [obj boolValue];
    }
    
}

- (NSInteger)integerForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:(id)[NSNull null]]) {
        return 0;
    } else {
        return [obj integerValue];
    }
}

- (NSNumber *)numberForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:(id)[NSNull null]]) {
        return nil;
    } else {
        return [NSNumber numberWithUnsignedLongLong:[obj unsignedLongLongValue]];
    }
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)obj;
    } else {
        return nil;
    }
}

- (NSArray *)arrayForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    } else {
        return nil;
    }
}

@end

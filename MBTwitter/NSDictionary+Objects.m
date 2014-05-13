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
    
    if (obj != [NSNull null]) {
        return [obj integerValue];
    } else {
        return 0;
    }
}

- (NSNumber *)numberForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    
    if (obj != [NSNull null]) {
        return [NSNumber numberWithUnsignedLongLong:[obj unsignedLongLongValue]];;
    } else {
        return nil;
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

- (NSMutableArray *)mutableArrayForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSMutableArray class]]) {
        return (NSMutableArray *)obj;
    } else {
        return nil;
    }
}

- (NSValue *)valueObjForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSValue class]]) {
        return (NSValue *)obj;
    } else {
        return nil;
    }
}

@end

//
//  NSString+UUID.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)stringWithNewUUID
{
    CFUUIDRef newUUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef stringWithUUID = CFUUIDCreateString(kCFAllocatorDefault, newUUID);
    return (__bridge NSString *)stringWithUUID;
}

@end

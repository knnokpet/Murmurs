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
    NSString *uuidString = ( __bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, newUUID);
    CFRelease(newUUID);
    return uuidString;
}

@end

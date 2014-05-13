//
//  NSDate+strptime.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "NSDate+strptime.h"

#import <time.h>
#import <xlocale.h>

@implementation NSDate (strptime)

+ (NSDate *)parseDateUsingStrptime:(NSString *)dateString
{
    struct tm sometime;
    const char *formatString = [@"%a %b %d %H:%M:%S %z %Y" UTF8String];
    memset(&sometime, 0, sizeof(sometime));
    char *ret = strptime_l(dateString.UTF8String, formatString, &sometime, NULL);
    
    NSDate *parsedDate = nil;
    if (ret != '\0') {
        parsedDate = [NSDate dateWithTimeIntervalSince1970:timegm(&sometime)];
    } else if (ret == '\0') {
        
    }
    
    return parsedDate;
}

@end

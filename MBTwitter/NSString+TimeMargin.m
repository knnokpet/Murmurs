//
//  NSString+TimeMargin.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/07.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "NSString+TimeMargin.h"
#import <xlocale.h>

@implementation NSString (TimeMargin)

+ (NSString *)timeMarginWithDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    NSInteger secondsFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSInteger intervalUTC = interval + secondsFromGMT;
    
    NSLog(@"interval = %ld", (long)intervalUTC);
    
    NSInteger daySecond = 60 * 60 * 24;
    
    NSInteger first = intervalUTC / daySecond;
    if (1 <= first) {
        NSString *d = NSLocalizedString(@"day", nil);
        int day = (int)first;
        return [NSString stringWithFormat:@"%d%@", day, d];
    }
    
    NSInteger hourSecond = 60 * 60;
    NSInteger second = intervalUTC / hourSecond;
    if (1 <= second) {
        NSString *h = NSLocalizedString(@"h", nil);
        int hour = (int)second;
        return [NSString stringWithFormat:@"%d%@", hour, h];
    }
    
    NSInteger minuteSecond = 60;
    NSInteger third = intervalUTC / minuteSecond;
    if (1 <= third) {
        NSString *m = NSLocalizedString(@"m", nil);
        int minute = (int)third;
        return [NSString stringWithFormat:@"%d%@", minute, m];
    }
    
    if (0 < intervalUTC && 60 > intervalUTC) {
        return NSLocalizedString(@"Now", nil);
    }
    
    return @"";
}

@end

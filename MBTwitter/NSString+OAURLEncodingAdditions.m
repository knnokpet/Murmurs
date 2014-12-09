//
//  NSString+OAURLEncodingAdditions.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "NSString+OAURLEncodingAdditions.h"

@implementation NSString (OAURLEncodingAdditions)

- (NSString *)encodedString
{
    NSString *encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$&'()*+,;=%"), kCFStringEncodingUTF8);
    
    return encodedString;
}

- (NSString *)decodedString
{
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
    
    return decodedString;
}

@end

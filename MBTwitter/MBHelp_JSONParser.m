//
//  MBHelp_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBHelp_JSONParser.h"

@implementation MBHelp_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedHelp = (NSDictionary *)parsedObj;
        NSNumber *maxMediaPerUpload = [parsedHelp numberForKey:@"max_media_per_upload"];
        NSLog(@"maxmedia = %llu", [maxMediaPerUpload unsignedLongLongValue]);
    }
}

@end

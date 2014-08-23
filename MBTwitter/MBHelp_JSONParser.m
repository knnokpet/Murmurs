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
        NSNumber *photoSizeLimit = [parsedHelp numberForKey:@"photo_size_limit"];
        NSNumber *shortURLLength = [parsedHelp numberForKey:@"short_url_length_https"];
        NSLog(@"maxmedia = %llu photoSizeLimit %llu", [maxMediaPerUpload unsignedLongLongValue], [photoSizeLimit unsignedLongLongValue]);
        NSArray *helpArray = @[maxMediaPerUpload, shortURLLength, photoSizeLimit];
        self.completion(helpArray);
    }
}

@end

//
//  MBMediaLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMediaLink.h"

@implementation MBMediaLink

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    NSArray *indices = [dictionary objectForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];
    NSString *displayText = [dictionary objectForKey:@"display_url"];
    self.displayText = displayText;
    
    _mediaID = [[dictionary objectForKey:@"id"] integerValue];
    _mediaIDStr = [dictionary objectForKey:@"id_str"];
    _sizes = [dictionary objectForKey:@"sizes"];
    _sourceTweetID = [[dictionary objectForKey:@"source_status_id"] integerValue];
    _sourceTweetIDStr = [dictionary objectForKey:@"source_status_id_str"];
    _type = [dictionary objectForKey:@"type"];
    
    _expandedURLText = [dictionary objectForKey:@"expanded_url"];
    _originalURLText = [dictionary objectForKey:@"media_url"];
    _originalURLHttpsText = [dictionary objectForKey:@"media_url_https"];
    _wrappedURLText = [dictionary objectForKey:@"url"];
}

@end

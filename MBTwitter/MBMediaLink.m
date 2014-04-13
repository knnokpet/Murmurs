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
    NSArray *indices = [dictionary arrayForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];

    self.displayText = [dictionary stringForKey:@"display_url"];
    
    _mediaID = [dictionary numberForKey:@"id"];
    _mediaIDStr = [dictionary stringForKey:@"id_str"];
    _sizes = [dictionary dictionaryForKey:@"sizes"];
    _sourceTweetID = [dictionary numberForKey:@"source_status_id"];
    _sourceTweetIDStr = [dictionary stringForKey:@"source_status_id_str"];
    _type = [dictionary stringForKey:@"type"];
    
    _expandedURLText = [dictionary stringForKey:@"expanded_url"];
    _originalURLText = [dictionary stringForKey:@"media_url"];
    _originalURLHttpsText = [dictionary stringForKey:@"media_url_https"];
    _wrappedURLText = [dictionary stringForKey:@"url"];
}

@end

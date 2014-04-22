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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        NSArray *index = [aDecoder decodeObjectForKey:@"index"];
        self.textIndex = [[MBTextIndex alloc] initWithArray:index];
        self.displayText = [aDecoder decodeObjectForKey:@"displayText"];
        _mediaID = [aDecoder decodeObjectForKey:@"id"];
        _mediaIDStr = [aDecoder decodeObjectForKey:@"id_str"];
        _sizes = [aDecoder decodeObjectForKey:@"sizes"];
        _sourceTweetID = [aDecoder decodeObjectForKey:@"source_status_id"];
        _sourceTweetIDStr = [aDecoder decodeObjectForKey:@"source_status_id_str"];
        _type = [aDecoder decodeObjectForKey:@"type"];
        _expandedURLText = [aDecoder decodeObjectForKey:@"expanded_url"];
        _originalURLText = [aDecoder decodeObjectForKey:@"media_url"];
        _originalURLHttpsText = [aDecoder decodeObjectForKey:@"media_url_https"];
        _wrappedURLText = [aDecoder decodeObjectForKey:@"url"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSNumber *begin = [NSNumber numberWithInteger:self.textIndex.begin];
    NSNumber *end = [NSNumber numberWithInteger:self.textIndex.end];
    NSArray *index = [NSArray arrayWithObjects:begin, end, nil];
    [aCoder encodeObject:index forKey:@"index"];
    [aCoder encodeObject:self.displayText forKey:@"displayText"];
    [aCoder encodeObject:_mediaID forKey:@"id"];
    [aCoder encodeObject:_mediaIDStr forKey:@"id_str"];
    [aCoder encodeObject:_sizes forKey:@"sizes"];
    [aCoder encodeObject:_sourceTweetID forKey:@"source_status_id"];
    [aCoder encodeObject:_sourceTweetIDStr forKey:@"source_status_id_str"];
    [aCoder encodeObject:_type forKey:@"type"];
    [aCoder encodeObject:_expandedURLText forKey:@"expanded_url"];
    [aCoder encodeObject:_originalURLText forKey:@"media_url"];
    [aCoder encodeObject:_originalURLHttpsText forKey:@"media_url_https"];
    [aCoder encodeObject:_wrappedURLText forKey:@"url"];
}

@end

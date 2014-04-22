//
//  MBMentionUserLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMentionUserLink.h"

@implementation MBMentionUserLink

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    NSArray *indices = [dictionary objectForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];
    self.displayText = [dictionary stringForKey:@"name"];
    
    _userID = [dictionary numberForKey:@"id"];
    _userIDStr = [dictionary stringForKey:@"id_str"];
    _screenName = [dictionary stringForKey:@"screen_name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        NSArray *index = [aDecoder decodeObjectForKey:@"index"];
        self.textIndex = [[MBTextIndex alloc] initWithArray:index];
        self.displayText = [aDecoder decodeObjectForKey:@"displayText"];
        _userID = [aDecoder decodeObjectForKey:@"id"];
        _userIDStr = [aDecoder decodeObjectForKey:@"id_str"];
        _screenName = [aDecoder decodeObjectForKey:@"screen_name"];
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
    [aCoder encodeObject:_userID forKey:@"id"];
    [aCoder encodeObject:_userIDStr forKey:@"id_str"];
    [aCoder encodeObject:_screenName forKey:@"screen_name"];
}

@end

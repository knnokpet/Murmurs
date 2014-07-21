//
//  MBURLLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBURLLink.h"

@implementation MBURLLink
- (instancetype)initWithURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        _expandedURLText = urlString;
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    NSArray *indices = [dictionary objectForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];
    self.displayText = [dictionary stringForKey:@"display_url"];
    
    _expandedURLText = [dictionary stringForKey:@"expanded_url"];
    _wrappedURLText = [dictionary   stringForKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        NSArray *index = [aDecoder decodeObjectForKey:@"index"];
        self.textIndex = [[MBTextIndex alloc] initWithArray:index];
        self.displayText = [aDecoder decodeObjectForKey:@"displayText"];
        _expandedURLText = [aDecoder decodeObjectForKey:@"expanded_url"];
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
    [aCoder encodeObject:_expandedURLText forKey:@"expanded_url"];
    [aCoder encodeObject:_wrappedURLText forKey:@"url"];
}

@end

//
//  MBHashTagLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBHashTagLink.h"

@implementation MBHashTagLink

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    NSArray *indices = [dictionary arrayForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];

    self.displayText = [dictionary stringForKey:@"text"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        NSArray *index = [aDecoder decodeObjectForKey:@"index"];
        self.textIndex = [[MBTextIndex alloc] initWithArray:index];
        self.displayText = [aDecoder decodeObjectForKey:@"displayText"];
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
}

@end

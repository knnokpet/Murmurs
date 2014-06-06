//
//  MBGapedTweet.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBGapedTweet.h"

@implementation MBGapedTweet
- (id)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _index = index;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        NSNumber *indexNumber =[aDecoder decodeObjectForKey:@"index"];
        if (indexNumber) {
            _index = [indexNumber integerValue];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInteger:_index] forKey:@"index"];
}

@end

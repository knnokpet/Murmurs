//
//  MBTextIndex.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTextIndex.h"

@implementation MBTextIndex
- (id)initWithArray:(NSArray *)indices
{
    self = [super init];
    if (self) {
        _begin = [[indices firstObject] integerValue];
        _end = [[indices lastObject] integerValue];
    }
    
    return self;
}

@end

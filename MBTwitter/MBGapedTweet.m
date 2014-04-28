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

@end

//
//  MBGapedTweet.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweet.h"

@interface MBGapedTweet : MBTweet

@property (nonatomic) NSInteger index;

- (id)initWithIndex:(NSInteger)index;

@end

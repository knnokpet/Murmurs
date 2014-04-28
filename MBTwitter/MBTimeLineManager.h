//
//  MBTimeLineManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBTimeLineManager : NSObject

@property (nonatomic) NSArray *tweets;
@property (nonatomic, readonly) NSMutableArray *gaps;

- (NSDictionary *)addTweets:(NSArray *)tweets;

@end

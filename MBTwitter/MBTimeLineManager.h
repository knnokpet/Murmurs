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
@property (nonatomic, readonly) NSInteger saveIndex;
@property (nonatomic) CGPoint currentOffset;

- (NSDictionary *)addTweets:(NSArray *)tweets;
- (void)removeTweetAtIndex:(NSUInteger)index;
- (void)addSaveIndex;
- (void)stopLoadingSavedTweets;

@end

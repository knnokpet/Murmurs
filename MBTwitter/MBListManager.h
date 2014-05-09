//
//  MBListManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBList;
@interface MBListManager : NSObject

@property (nonatomic) NSMutableArray *lists;

- (void)addLists:(NSArray *)lists;
- (void)removeListAtIndex:(NSInteger )index;

@end

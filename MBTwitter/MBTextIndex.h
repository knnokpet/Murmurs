//
//  MBTextIndex.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBTextIndex : NSObject

@property (nonatomic, readonly) NSInteger begin;
@property (nonatomic, readonly) NSInteger end;

- (id)initWithArray:(NSArray *)indices;

@end

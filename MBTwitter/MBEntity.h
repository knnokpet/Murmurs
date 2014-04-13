//
//  MBEntity.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/31.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Objects.h"

@interface MBEntity : NSObject

@property (nonatomic, readonly) NSArray *hashtags;
@property (nonatomic, readonly) NSArray *media;
@property (nonatomic, readonly) NSArray *urls;
@property (nonatomic, readonly) NSArray *userMentions;

- (id)initWithDictionary:(NSDictionary *)entity;

@end

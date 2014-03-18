//
//  OAConsumer.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAConsumer : NSObject

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *secret;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;

@end

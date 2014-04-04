//
//  OAParameter.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAParameter : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *value;

+ (id)requestParameterWithName:(NSString *)name value:(NSString *)value;
- (id)initWithName:(NSString *)name value:(NSString *)value;

- (NSString *)encodedNameValuePair;

@end

//
//  NSString+OAURLEncodingAdditions.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OAURLEncodingAdditions)

- (NSString *)encodedString;
- (NSString *)decodedString;

@end

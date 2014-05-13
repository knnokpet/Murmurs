//
//  NSDate+strptime.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (strptime)

+ (NSDate *)parseDateUsingStrptime:(NSString *)dateString;

@end

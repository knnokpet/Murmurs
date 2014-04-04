//
//  NSDate+SQLite.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/02.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SQLite)

+ (NSDate *)parsedDatUsingSQLiteWithString:(NSString *)dateString;

@end

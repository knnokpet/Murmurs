//
//  MBHashTagLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBHashTagLink.h"

@implementation MBHashTagLink

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    NSArray *indices = [dictionary objectForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];
    NSString *hashTagName = [dictionary objectForKey:@"text"];
    self.displayText = hashTagName;
}

@end

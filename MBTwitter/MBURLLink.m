//
//  MBURLLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBURLLink.h"

@implementation MBURLLink

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    NSArray *indices = [dictionary objectForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];
    self.displayText = [dictionary stringForKey:@"display_url"];
    
    _expandedURLText = [dictionary stringForKey:@"expanded_url"];
    _wrappedURLText = [dictionary   stringForKey:@"url"];
}

@end

//
//  MBMentionUserLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMentionUserLink.h"

@implementation MBMentionUserLink

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    NSArray *indices = [dictionary objectForKey:@"indices"];
    self.textIndex = [[MBTextIndex alloc] initWithArray:indices];
    self.displayText = [dictionary objectForKey:@"name"];
    
    _userID = [NSNumber numberWithUnsignedLongLong:[[dictionary objectForKey:@"id"] unsignedLongLongValue]];
    _userIDStr = [dictionary objectForKey:@"id_str"];
    _screenName = [dictionary objectForKey:@"screen_name"];
}

@end

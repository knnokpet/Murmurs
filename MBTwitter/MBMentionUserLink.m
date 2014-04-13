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
    self.displayText = [dictionary stringForKey:@"name"];
    
    _userID = [dictionary numberForKey:@"id"];
    _userIDStr = [dictionary stringForKey:@"id_str"];
    _screenName = [dictionary stringForKey:@"screen_name"];
}

@end

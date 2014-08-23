//
//  MBUsers_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsers_JSONParser.h"

@implementation MBUsers_JSONParser
- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedDict = (NSDictionary *)parsedObj;
        
        NSMutableArray *users = [NSMutableArray array];
        NSArray *parsedUsers = [parsedDict arrayForKey:@"users"];
        for (NSDictionary *parsedUser in parsedUsers) {
            MBUser *user = [[MBUser alloc] initWithDictionary:parsedUser];
            [[MBUserManager sharedInstance] storeUser:user]; /* フォロー、フォロワー、リストユーザーまるごと保持してみる */
            [users addObject:user];
        }
        NSNumber *next = [parsedDict numberForKey:@"next_cursor"];
        NSNumber *previous = [parsedDict numberForKey:@"previous_cursor"];
        
        self.completionWithCursor(users, next, previous);
    }
}

@end

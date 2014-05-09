//
//  MBListMembers_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListMembers_JSONParser.h"

@implementation MBListMembers_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedObjDict = (NSDictionary *)parsedObj;
        
        NSMutableArray *users = [NSMutableArray array];
        NSArray *parsedUsers = [parsedObjDict arrayForKey:@"users"];
        for (NSDictionary *parsedUser in parsedUsers) {
            MBUser *user = [[MBUser alloc] initWithDictionary:parsedUser];
            [[MBUserManager sharedInstance] storeUser:user];
            [users addObject:user];
        }
        NSNumber *next = [parsedObjDict numberForKey:@"previous_cursor"];
        NSNumber *previous = [parsedObjDict numberForKey:@"next_cursor"];
        
        self.completionWithCursor(users, next, previous);
    }
}

@end

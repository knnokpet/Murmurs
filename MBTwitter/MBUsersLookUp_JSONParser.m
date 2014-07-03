//
//  MBUsersLookUp_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsersLookUp_JSONParser.h"

@implementation MBUsersLookUp_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSArray class]]) {
        NSArray *parsedArray = (NSArray *)parsedObj;
        
        NSMutableArray *parsedUsers = [NSMutableArray arrayWithCapacity:100];
        for (NSDictionary *parsedDict in parsedArray) {
            MBUser *user = [[MBUser alloc] initWithDictionary:parsedDict];
            [[MBUserManager sharedInstance] storeUser:user];
            [parsedUsers addObject:user];
        }
        
        self.completion(parsedUsers);
    }
}

@end

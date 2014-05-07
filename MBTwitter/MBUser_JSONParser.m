//
//  MBUser_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUser_JSONParser.h"

@implementation MBUser_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        MBUser *user = [[MBUser alloc] initWithDictionary:(NSDictionary *)parsedObj];
        [[MBUserManager sharedInstance] storeUser:user];
        NSArray *gotUser = [NSArray arrayWithObject:user];
        self.completion(gotUser);
    }
}

@end

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
        NSArray *errorArray= [(NSDictionary *)parsedObj arrayForKey:@"errors"];
        if (errorArray) {
            NSDictionary *errorDict = (NSDictionary *)[errorArray lastObject];
            NSInteger code = [errorDict integerForKey:@"code"];
            NSString *message = [errorDict stringForKey:@"message"];
            NSError *error = [NSError errorWithDomain:message code:code userInfo:nil];
            [self failedParsing:error];
            return;
        }
        
        MBUser *user = [[MBUser alloc] initWithDictionary:(NSDictionary *)parsedObj];
        [[MBUserManager sharedInstance] storeUser:user];
        NSArray *gotUser = [NSArray arrayWithObject:user];
        self.completion(gotUser);
    }
}

@end

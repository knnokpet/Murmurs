//
//  MBDirectMessages_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDirectMessages_JSONParser.h"
#import "MBDirectMessageManager.h"
#import "MBDirectMessage.h"

@implementation MBDirectMessages_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *errorDict = (NSDictionary *)parsedObj;
        NSArray *errors = [errorDict arrayForKey:@"errors"];
        if (errors) {
            NSInteger code = [(NSDictionary *)[errors lastObject] integerForKey:@"code"];
            NSString *message = [(NSDictionary *)[errors lastObject] stringForKey:@"message"];
            NSError *error = [NSError errorWithDomain:message code:code userInfo:nil];
            [self failedParsing:error];
        }
    } else if ([parsedObj isKindOfClass:[NSArray class]]) {
        NSLog(@"parsed count = %d", [(NSArray *)parsedObj count]);
        NSMutableArray *gotMessages = [NSMutableArray arrayWithCapacity:200];
        for (NSDictionary *parsedMessage in (NSArray *)parsedObj) {
            MBDirectMessage *message = [[MBDirectMessage alloc] initWithDictionary:parsedMessage];
            [[MBDirectMessageManager sharedInstance] storeMessage:message];
            [gotMessages addObject:message];
        }
        
        self.completion(gotMessages);
    }
}

@end

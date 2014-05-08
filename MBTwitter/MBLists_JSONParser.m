//
//  MBLists_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLists_JSONParser.h"
#import "MBList.h"

@implementation MBLists_JSONParser
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
        NSMutableArray *gotLists = [NSMutableArray arrayWithCapacity:100];
        for (NSDictionary *parsedList in (NSArray *)parsedObj) {
            MBList *list = [[MBList alloc] initWithDictionary:parsedList];
            [gotLists addObject:list];
        }
        
        self.completion(gotLists);
    }
}

@end

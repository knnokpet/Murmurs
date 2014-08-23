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
        NSDictionary *parsedDict = (NSDictionary *)parsedObj;
        
        NSMutableArray *lists = [NSMutableArray arrayWithCapacity:100];
        NSArray *parsedLists = [parsedDict arrayForKey:@"lists"];
        for (NSDictionary *parsedList in parsedLists) {
            MBList *list = [[MBList alloc] initWithDictionary:parsedList];
            [lists addObject:list];
        }
        NSNumber *next = [parsedObj numberForKey:@"next_cursor"];
        NSNumber *previous = [parsedObj numberForKey:@"previous_cursor"];
        
        self.completionWithCursor(lists, next, previous);
        
    }
}

@end

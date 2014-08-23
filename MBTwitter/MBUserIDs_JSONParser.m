//
//  MBUserIDs_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUserIDs_JSONParser.h"

@implementation MBUserIDs_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedDict = (NSDictionary *)parsedObj;
        
        NSArray *ids = [parsedDict arrayForKey:@"ids"];
        NSNumber *previousCursor = [parsedDict numberForKey:@"previous_cursor"];
        NSNumber *nextCursor = [parsedDict numberForKey:@"next_cursor"];
        
        self.completionWithCursor(ids, nextCursor, previousCursor);
    }
}

@end

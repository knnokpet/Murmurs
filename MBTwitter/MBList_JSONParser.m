//
//  MBList_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBList_JSONParser.h"
#import "MBList.h"

@implementation MBList_JSONParser
- (void)configure:(id)parsedObj
{
    NSLog(@"listParse");
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedListDict = (NSDictionary *)parsedObj;
        MBList *list = [[MBList alloc] initWithDictionary:parsedListDict];
        NSArray *gotList = @[list];
        
        self.completion(gotList);
    }
}

@end

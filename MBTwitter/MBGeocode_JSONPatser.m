//
//  MBGeocode_JSONPatser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBGeocode_JSONPatser.h"
#import "MBPlace.h"

@implementation MBGeocode_JSONPatser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedDict = (NSDictionary *)parsedObj;
        NSDictionary *result = [parsedDict dictionaryForKey:@"result"];
        NSArray *places = [result arrayForKey:@"places"];
        
        NSMutableArray *gotPlaces = [NSMutableArray arrayWithCapacity:[places count]];
        
        for (NSDictionary *dict in places) {
            MBPlace *place = [[MBPlace alloc] initWithDictionary:dict];
            [gotPlaces addObject:place];
        }
        
        self.completion(gotPlaces);
    }
}

@end

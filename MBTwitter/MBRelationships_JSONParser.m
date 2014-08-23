//
//  MBRelationships_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBRelationships_JSONParser.h"
#import "MBRelationship.h"

@implementation MBRelationships_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSArray class]]) {
        NSArray *parsedRelationships = (NSArray *)parsedObj;

        
        NSMutableArray *gotRelationships = [NSMutableArray arrayWithCapacity:100];
        for (NSDictionary *dict in parsedRelationships) {
            MBRelationship *relationsihp = [[MBRelationship alloc] initWithDictionary:dict];
            [gotRelationships addObject:relationsihp];
        }
        
        self.completion(gotRelationships);
    }
}

@end

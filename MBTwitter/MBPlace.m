//
//  MBPlace.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/31.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBPlace.h"

@implementation MBPlace
- (id)initWithDictionary:(NSDictionary *)place
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:place];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)place
{
    _attributes = [place dictionaryForKey:@"attributes"];
    _boundingBox = [[[place dictionaryForKey:@"bounding_box"] arrayForKey:@"coordinates"] firstObject];
    _countryName = [place stringForKey:@"country"];
    _countryCode = [place stringForKey:@"country_code"];
    _countryFullName = [place stringForKey:@"full_name"];
    _placeID = [place stringForKey:@"id"];
    _counttyShortName = [place stringForKey:@"name"];
    _type = [place stringForKey:@"place_type"];
    _urlForLocation = [place stringForKey:@"url"];
}

@end

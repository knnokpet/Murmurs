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
    _attributes = [place objectForKey:@"attributes"];
    _boundingBox = [[[place objectForKey:@"bounding_box"] objectForKey:@"coordinates"] firstObject];
    _countryName = [place objectForKey:@"country"];
    _countryCode = [place objectForKey:@"country_code"];
    _countryFullName = [place objectForKey:@"full_name"];
    _placeID = [place objectForKey:@"id"];
    _counttyShortName = [place objectForKey:@"name"];
    _type = [place objectForKey:@"place_type"];
    _urlForLocation = [place objectForKey:@"url"];
}

@end

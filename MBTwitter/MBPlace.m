//
//  MBPlace.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/31.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBPlace.h"

#define KEY_ATTRIBUTES @"attributes"
#define KEY_BOUNDING_BOX @"bounding_box"
#define KEY_COORDINATES @"coordinates"
#define KEY_COUNTRY @"country"
#define KEY_COUNTRY_CODE @"country_code"
#define KEY_COUNTRY_FULL_NAME @"full_name"
#define KEY_PLACE_ID @"id"
#define KEY_COUNTRY_SHORT_NAME @"name"
#define KEY_TYPE @"place_type"
#define KEY_URL @"url"

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
    _attributes = [place dictionaryForKey:KEY_ATTRIBUTES];
    _boundingBox = [[[place dictionaryForKey:KEY_BOUNDING_BOX] arrayForKey:KEY_COORDINATES] firstObject];
    _countryName = [place stringForKey:KEY_COUNTRY];
    _countryCode = [place stringForKey:KEY_COUNTRY_CODE];
    _countryFullName = [place stringForKey:KEY_COUNTRY_FULL_NAME];
    _placeID = [place stringForKey:KEY_PLACE_ID];
    _countryShortName = [place stringForKey:KEY_COUNTRY_SHORT_NAME];
    _type = [place stringForKey:KEY_PLACE_ID];
    _urlForLocation = [place stringForKey:KEY_URL];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _attributes = [aDecoder decodeObjectForKey:KEY_ATTRIBUTES];
        _boundingBox = [aDecoder decodeObjectForKey:KEY_COORDINATES];
        _countryName = [aDecoder decodeObjectForKey:KEY_COUNTRY];
        _countryCode = [aDecoder decodeObjectForKey:KEY_COUNTRY_CODE];
        _countryFullName = [aDecoder decodeObjectForKey:KEY_COUNTRY_FULL_NAME];
        _placeID = [aDecoder decodeObjectForKey:KEY_PLACE_ID];
        _countryShortName = [aDecoder decodeObjectForKey:KEY_COUNTRY_SHORT_NAME];
        _type = [aDecoder decodeObjectForKey:KEY_PLACE_ID];
        _urlForLocation = [aDecoder decodeObjectForKey:KEY_URL];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_attributes forKey:KEY_ATTRIBUTES];
    [aCoder encodeObject:_boundingBox forKey:KEY_COORDINATES];
    [aCoder encodeObject:_countryName forKey:KEY_COUNTRY];
    [aCoder encodeObject:_countryCode forKey:KEY_COUNTRY_CODE];
    [aCoder encodeObject:_countryFullName forKey:KEY_COUNTRY_FULL_NAME];
    [aCoder encodeObject:_placeID forKey:KEY_PLACE_ID];
    [aCoder encodeObject:_countryShortName forKey:KEY_COUNTRY_SHORT_NAME];
    [aCoder encodeObject:_type forKey:KEY_TYPE];
    [aCoder encodeObject:_urlForLocation forKey:KEY_URL];
}

@end

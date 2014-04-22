//
//  MBPlace.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/31.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Objects.h"

@interface MBPlace : NSObject <NSCoding>

@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, readonly) NSArray *boundingBox; // Array で保持してみる
@property (nonatomic, readonly) NSString *countryName;
@property (nonatomic, readonly) NSString *countryCode;
@property (nonatomic, readonly) NSString *countryFullName;
@property (nonatomic, readonly) NSString *placeID;
@property (nonatomic, readonly) NSString *countryShortName;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *urlForLocation;

- (id)initWithDictionary:(NSDictionary *)place;

@end

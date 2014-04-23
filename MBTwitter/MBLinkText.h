//
//  MBLinkText.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBTextGeo;
@interface MBLinkText : NSObject

@property (nonatomic, readonly) NSString *linkText;
@property (nonatomic, readonly) id obj;
@property (nonatomic, readonly) NSRange textRange;
@property (nonatomic, readonly) NSArray *geometries;

- (id)initWithText:(NSString *)linkText object:(id)object range:(NSRange)range;

- (void)addTextGeometory:(MBTextGeo *)geo;

@end

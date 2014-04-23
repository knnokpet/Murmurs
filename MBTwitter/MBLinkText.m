//
//  MBLinkText.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLinkText.h"

@implementation MBLinkText

- (id)initWithText:(NSString *)linkText object:(id)object range:(NSRange)range
{
    self = [super init];
    if (self) {
        _linkText = linkText;
        _obj = object;
        _textRange = range;
        
        _geometries = [NSArray array];
    }
    
    return self;
}

- (void)addTextGeometory:(MBTextGeo *)geo
{
    _geometries = [self.geometries arrayByAddingObject:geo];
}

@end

//
//  MBTextGeo.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTextGeo.h"

@implementation MBTextGeo

- (id)initWithRect:(CGRect)rect lineIndex:(NSNumber *)index
{
    self = [super init];
    if (self) {
        _rect = rect;
        _lineIndex = index;
    }
    
    return self;
}

@end

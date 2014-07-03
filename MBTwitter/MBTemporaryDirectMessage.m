//
//  MBTemporaryDirectMessage.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/18.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTemporaryDirectMessage.h"

@implementation MBTemporaryDirectMessage

- (instancetype)initWithText:(NSString *)text partner:(MBUser *)partner
{
    self = [super init];
    if (self) {
        _partner = partner;
        _text = text;
    }
    
    return self;
}

@end

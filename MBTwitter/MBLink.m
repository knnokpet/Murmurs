//
//  MBLink.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLink.h"

@implementation MBLink
- (id)initWithDictionary:(NSDictionary *)linkDict
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:linkDict];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)dictionary
{
    // override in subclass
}

#pragma mark -
#pragma mark Accessoer
- (void)setTextIndex:(MBTextIndex *)textIndex
{
    _textIndex = textIndex;
}

- (void)setDisplayText:(NSString *)displayText
{
    _displayText = displayText;
}


@end

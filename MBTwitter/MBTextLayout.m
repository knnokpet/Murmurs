//
//  MBTextLayout.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTextLayout.h"

@implementation MBTextLayout

#pragma mark -
#pragma mark
- (id)initWithAttributedString:(NSAttributedString *)attributedString
{
    self = [super init];
    if (self) {
        _attributedString = attributedString;
    }
    
    return self;
}

#pragma mark -
#pragma mark Frame
+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize
{
    CGRect drawingRect = [attributedString boundingRectWithSize:constraintSize options:NSStringDrawingUsesFontLeading context:nil];
    return drawingRect;
}

#pragma mark -
#pragma mark Draw


@end

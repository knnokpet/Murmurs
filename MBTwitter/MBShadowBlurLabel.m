//
//  MBShadowBlurLabel.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/19.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBShadowBlurLabel.h"

@implementation MBShadowBlurLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 6.0f);
    UIColor *shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 6.0f, shadowColor.CGColor);
    [super drawRect:rect];
    CGContextRestoreGState(context);
}


@end

//
//  MBUnderLineToolbar.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/18.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUnderLineToolbar.h"

@implementation MBUnderLineToolbar

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
    [super drawRect:rect];
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bound = self.bounds;
    CGFloat lineWidth = 0.5f;
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.5f);
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(bound));
    CGContextAddLineToPoint(context, CGRectGetWidth(bound), CGRectGetHeight(bound));
    CGContextStrokePath(context);
}


@end

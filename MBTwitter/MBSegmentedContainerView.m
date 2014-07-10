//
//  MBSegmentedContainerView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSegmentedContainerView.h"

@implementation MBSegmentedContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
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
    CGRect bounds = self.bounds;
    CGFloat lineWidth = 0.5f;
    
    // fill color
    CGFloat r, g, b, a;
    r = 1.0;
    g = 1.0;
    b = 1.0;
    a = 0.5;
    CGFloat components[4] = {r, g, b, a};
    CGContextSetFillColor(context, components);
    CGContextFillRect(context, bounds);
    
    // path line
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.5);
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(bounds));
    CGContextAddLineToPoint(context, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    CGContextStrokePath(context);
}


@end

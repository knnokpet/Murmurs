//
//  MBListSegmentedContainerView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListSegmentedContainerView.h"

@implementation MBListSegmentedContainerView

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
    
    CGRect bounds = self.bounds;
    CGFloat lineWidth = 0.5f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.5);
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, 0, bounds.size.height);
    CGContextAddLineToPoint(context, bounds.size.width, bounds.size.height);
    CGContextStrokePath(context);
    
}


@end

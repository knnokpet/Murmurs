//
//  MBMessageView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMessageView.h"

@implementation MBMessageView
- (void)awakeFromNib
{
    [self setPopsFromRight:NO];
    self.contentMode = UIViewContentModeRedraw;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPopsFromRight:(BOOL)popsFromRight
{
    _popsFromRight = popsFromRight;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawPopInContext:context];
}

- (void)drawPopInContext:(CGContextRef )context
{
    CGFloat r, g, b, a;
    r = 0.9;
    g = 0.9;
    b = 0.9;
    a = 1.0;
    if (self.popsFromRight) {
        r = 0;
        g = 0.4;
        b = 0.8;
    }
    CGFloat components[4] = {r, g, b, a};
    CGContextSetStrokeColor(context, components);
    CGContextSetFillColor(context, components);
    
    CGRect bouds = self.bounds;
    CGFloat spaceWidth = 8.0f;
    CGFloat radius = 16.0f;
    
    
    
    CGPoint popPoint = CGPointZero;
    
    // roundRectPoints
    CGFloat minX, nealyX, maxX, farX;
    CGFloat minY, nealyY, maxY, farY;
    
    if (self.popsFromRight) {
        popPoint = CGPointMake(CGRectGetMaxX(bouds), CGRectGetMaxY(bouds));
        
        minX = CGRectGetMinX(bouds);
        nealyX = radius;
        maxX = CGRectGetMaxX(bouds) - spaceWidth;
        farX = maxX - radius;
        minY = CGRectGetMinY(bouds);
        nealyY = radius;
        maxY = CGRectGetMaxY(bouds);
        farY = maxY - radius;
        
        CGContextMoveToPoint(context, minX, nealyY);
        CGContextAddArcToPoint(context, minX, minY, nealyX, minY, radius);
        CGContextAddLineToPoint(context, farX, minY);
        CGContextAddArcToPoint(context, maxX, minY, maxX, nealyY, radius);
        CGContextAddLineToPoint(context, maxX, farY);
        
        CGContextAddArcToPoint(context, maxX, maxY, popPoint.x, popPoint.y, 12.0f);
        CGContextAddLineToPoint(context, nealyX, maxY);
        CGContextAddArcToPoint(context, minX, maxY, minX, farY, radius);
        CGContextAddLineToPoint(context, minX, nealyY);
        
    } else {
        // Fukidashi
        popPoint = CGPointMake(CGRectGetMinX(bouds), CGRectGetMaxY(bouds));
        
        // roundRectPoints
        minX = CGRectGetMinX(bouds) + spaceWidth;
        nealyX = radius;
        maxX = CGRectGetMaxX(bouds);
        farX = maxX - radius;
        minY = CGRectGetMinY(bouds);
        nealyY = radius;
        maxY = CGRectGetMaxY(bouds);
        farY = maxY - radius;
        
        CGContextMoveToPoint(context, minX, nealyY);
        CGContextAddArcToPoint(context, minX, minY, nealyX, minY, radius);
        CGContextAddLineToPoint(context, farX, minY);
        CGContextAddArcToPoint(context, maxX, minY, maxX, nealyY, radius);
        CGContextAddLineToPoint(context, maxX, farY);
        CGContextAddArcToPoint(context, maxX, maxY, farX, maxY, radius);
        
        CGContextAddLineToPoint(context, popPoint.x, popPoint.y);
        CGContextAddArcToPoint(context, minX, maxY, minX, maxY - spaceWidth, 12.0f);
        CGContextAddLineToPoint(context, minX, nealyY);
    }
    
    
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

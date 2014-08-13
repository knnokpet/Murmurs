//
//  MBFavoriteView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBFavoriteView.h"

@implementation MBFavoriteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    _favorited = NO;
    _geod = NO;
}

- (void)setFavorited:(BOOL)favorited
{
    _favorited = favorited;
    [self setNeedsDisplay];
}

- (void)setGeod:(BOOL)geod
{
    _geod = geod;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGFloat division3Width = self.bounds.size.width / 3;
    
    CGRect drawRect = bounds;
    drawRect.origin.x = drawRect.size.width - division3Width;
    drawRect.size.width = division3Width;
    if (self.favorited == YES) {
        [self drawFavostarInContext:context inRect:drawRect];
        drawRect.origin.x = drawRect.origin.x - division3Width;
    }
    
    if (self.geod == YES) {
        [self drawGeoArrowInContext:context InRect:drawRect];
    }
}

- (void)drawFavostarInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSetRGBStrokeColor(context, 1.0, 0.8, 0, 1.0);
    CGContextSetRGBFillColor(context, 1.0f, 0.8, 0.f, 1.0f);
    CGContextSetLineWidth(context, 1.0f);
    
    CGRect bound = self.bounds;
    CGFloat starRadius = 6.0f;
    CGPoint center = CGPointMake(rect.origin.x + starRadius / 2, bound.size.height / 2);
    CGContextMoveToPoint(context, center.x, center.y - starRadius);
    for (int i = 1; i < 5; ++i) {
        CGFloat x = starRadius * sinf(i * 4.0 * M_PI / 5.0);
        CGFloat y = starRadius * cosf(i * 4.0 * M_PI / 5.0);
        CGContextAddLineToPoint(context, center.x - x, center.y - y);
    }
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawPinInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSetRGBStrokeColor(context, 0, 0, 0.5, 1.0);
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.5f, 1.0f);
    CGContextSetLineWidth(context, 1.0f);
    
    CGFloat ellipseWidth = 8.0f;
    CGRect ellipseRect = CGRectMake((rect.origin.x +rect.size.width) / 2 - ellipseWidth / 2, 0, ellipseWidth, ellipseWidth);
    CGContextFillEllipseInRect(context, ellipseRect);
    
    CGContextSetLineWidth(context, 2.0f);
    CGPoint linePoint = CGPointMake((rect.origin.x + rect.size.width) / 2, ellipseRect.origin.y + ellipseRect.size.height);
    CGContextMoveToPoint(context, linePoint.x, linePoint.y);
    CGContextAddLineToPoint(context, linePoint.x, rect.origin.y + rect.size.height);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
}

- (void)drawGeoArrowInContext:(CGContextRef)context InRect:(CGRect)rect
{
    CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.9, 1.0f);
    CGContextSetRGBFillColor(context, 0.0, 0.4, 0.9, 1.0);
    CGContextSetLineWidth(context, 1.0f);
    
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat rectWidth = rect.size.width / 2;
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, 0, center.y);
    CGContextAddLineToPoint(context, center.x + rectWidth, center.y - rectWidth);
    CGContextAddLineToPoint(context, center.x, center.y + rectWidth);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

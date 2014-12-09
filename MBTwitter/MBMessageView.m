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
    [self commonInit];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setPopsFromRight:NO];
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
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
    r = 0.92;
    g = 0.92;
    b = 0.90;
    a = 1.0;
    if (self.popsFromRight) {
        r = 0.17;
        g = 0.58;
        b = 1.0;
    }
    
    CGFloat strokeR, strokeG, strokeB, strokeA;
    strokeA = 1.0;
    strokeR = 0.85;
    strokeG = 0.85;
    strokeB = 0.85;
    CGFloat strokeWidth = 1.0;
    
    CGRect bouds = self.bounds;
    CGFloat spaceWidth = 8.0f;
    CGFloat radius = 16.0f;
    
    
    
    CGPoint popPoint = CGPointZero;
    
    
    UIBezierPath *bezierPath;
    if (self.popsFromRight) {
        popPoint = CGPointMake(CGRectGetMaxX(bouds), CGRectGetMaxY(bouds));
        CGRect bezierRect = CGRectMake(CGRectGetMinX(bouds), CGRectGetMinY(bouds), CGRectGetWidth(bouds) - spaceWidth, CGRectGetHeight(bouds));
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bezierRect cornerRadius:radius];
        [bezierPath addLineToPoint:CGPointMake(bezierRect.size.width, bezierRect.size.height - radius)];
        CGPoint controlPoint = CGPointMake(bezierRect.size.width, bezierRect.size.height);
        [bezierPath addQuadCurveToPoint:popPoint controlPoint:controlPoint];
        [bezierPath addQuadCurveToPoint:CGPointMake(bezierRect.size.width - radius, bezierRect.size.height - radius / 2) controlPoint:controlPoint];

        [[UIColor colorWithRed:r green:g blue:b alpha:a] setFill];
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        UIColor *gradientStartColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
        UIColor *gradientEndColor = [UIColor colorWithRed:0.1 green:0.55 blue:1.0 alpha:a];
        NSArray *gradientColors = @[(id)gradientStartColor.CGColor, (id)gradientEndColor.CGColor];
        CGFloat gradientLocations[] = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpaceRef, (CFArrayRef)gradientColors, gradientLocations);
        CGContextSaveGState(context);
        [bezierPath fill];
        [bezierPath addClip];
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, CGRectGetHeight(bouds)), 0);
        CGColorSpaceRelease(colorSpaceRef);
        CGGradientRelease(gradient);
        CGContextRestoreGState(context);
        
    } else {
        // Fukidashi
        popPoint = CGPointMake(CGRectGetMinX(bouds), CGRectGetMaxY(bouds));
        
        CGRect bezierRect = CGRectMake(CGRectGetMinX(bouds) + spaceWidth, CGRectGetMinY(bouds), CGRectGetWidth(bouds) - spaceWidth, CGRectGetHeight(bouds));
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bezierRect cornerRadius:radius];
        [bezierPath addLineToPoint:CGPointMake(bezierRect.origin.x + radius, bezierRect.size.height - radius / 2)];
        CGPoint controlPoint = CGPointMake(spaceWidth, CGRectGetMaxY(bouds));
        [bezierPath addQuadCurveToPoint:popPoint controlPoint:controlPoint];
        [bezierPath addQuadCurveToPoint:CGPointMake(bezierRect.origin.x, bezierRect.size.height - radius) controlPoint:controlPoint];
        
        [[UIColor colorWithRed:r green:g blue:b alpha:a] setFill];
        [[UIColor colorWithRed:strokeR green:strokeG blue:strokeB alpha:strokeA] setStroke];
        bezierPath.lineWidth = strokeWidth;
        //[bezierPath stroke];
        [bezierPath fill];
    }
    
}

@end

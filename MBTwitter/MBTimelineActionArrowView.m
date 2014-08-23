//
//  MBTimelineActionArrowView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineActionArrowView.h"

@implementation MBTimelineActionArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/* unused */
- (instancetype)initWithFrame:(CGRect)frame isUpperArrow:(BOOL)isUpper
{
    self = [super initWithFrame:frame];
    if (self) {
        _isUpper = isUpper;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void)setIsUpper:(BOOL)isUpper
{
    _isUpper = isUpper;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
    [self drawBlackArrow];
    [self maskTransparent];
}

- (void)drawBlurArrow
{
    UIBezierPath *leftBezeirPath = [UIBezierPath bezierPath];
    UIBezierPath *rightBezierPath = [UIBezierPath bezierPath];
    CGSize size = self.frame.size;
    if (self.isUpper) {
        [leftBezeirPath moveToPoint:CGPointZero];
        [leftBezeirPath addLineToPoint:CGPointMake(0, size.height)];
        [leftBezeirPath addLineToPoint:CGPointMake(size.width / 2, 0)];
        
        [rightBezierPath moveToPoint:CGPointMake(size.width, 0)];
        [rightBezierPath addLineToPoint:CGPointMake(size.width, size.height)];
        [rightBezierPath addLineToPoint:CGPointMake(size.width / 2, 0)];
    } else {
        [leftBezeirPath moveToPoint:CGPointZero];
        [leftBezeirPath addLineToPoint:CGPointMake(0, size.height)];
        [leftBezeirPath addLineToPoint:CGPointMake(size.width / 2, size.height)];
        
        [rightBezierPath moveToPoint:CGPointMake(size.width, 0)];
        [rightBezierPath addLineToPoint:CGPointMake(size.width, size.height)];
        [rightBezierPath addLineToPoint:CGPointMake(size.width / 2, size.height)];
    }
    [leftBezeirPath closePath];
    [rightBezierPath closePath];
    [[UIColor whiteColor] setFill];
    [leftBezeirPath fill];
    [rightBezierPath fill];
}

- (void)drawBlackArrow
{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGSize size = self.frame.size;
    
    if (self.isUpper) {
        [arrowPath moveToPoint:CGPointMake(0, size.height)];
        [arrowPath addLineToPoint:CGPointMake(size.width / 2, 0)];
        [arrowPath addLineToPoint:CGPointMake(size.width, size.height)];

    } else {
        [arrowPath moveToPoint:CGPointZero];
        [arrowPath addLineToPoint:CGPointMake(size.width / 2, size.height)];
        [arrowPath addLineToPoint:CGPointMake(size.width, 0)];
    }
    
    [arrowPath closePath];
    [self.color setFill];
    [arrowPath fill];
}

- (void)maskTransparent
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f].CGColor, (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor, nil];
    
    CGPoint startPoint = CGPointMake(0, 0.0f);
    CGPoint endPoint = CGPointMake(0, 1.0f);
    gradientLayer.startPoint = CGPointMake(0, 0.0f);
    gradientLayer.endPoint = CGPointMake(0, 1.0f);
    if (self.isUpper) {
        gradientLayer.startPoint = endPoint;
        gradientLayer.endPoint = startPoint;
    }
    
    
    
    self.layer.mask = gradientLayer;
}

@end

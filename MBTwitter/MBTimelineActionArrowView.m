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


@end

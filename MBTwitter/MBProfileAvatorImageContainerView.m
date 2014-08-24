//
//  MBProfileAvatorImageContainerView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBProfileAvatorImageContainerView.h"

@interface MBProfileAvatorImageContainerView()
{
    CGFloat cornerRadius;
}

@end

@implementation MBProfileAvatorImageContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withCornerRadius:(CGFloat)radius
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        cornerRadius = radius;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.5);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 0.5f);
    
    CGSize boundSize = self.bounds.size;
    CGPoint start = CGPointMake(boundSize.width / 2, 0);

    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddArcToPoint(context, boundSize.width, 0, boundSize.width, boundSize.height, cornerRadius);
    CGContextAddArcToPoint(context, boundSize.width, boundSize.height, boundSize.width / 2, boundSize.height, cornerRadius);
    CGContextAddArcToPoint(context, 0, boundSize.height, 0, boundSize.height / 2, cornerRadius);
    CGContextAddArcToPoint(context, 0, 0, start.x, start.y, cornerRadius);
    CGContextClosePath(context);

    CGContextDrawPath(context, kCGPathFillStroke);
}


@end

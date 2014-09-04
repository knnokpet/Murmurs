//
//  MBPlaceWithGeoIconView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBPlaceWithGeoIconView.h"

@interface MBPlaceWithGeoIconView()
{
    CGRect placeNameRect;
}

@end

@implementation MBPlaceWithGeoIconView

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
}

- (void)setPlaceString:(NSAttributedString *)placeString
{
    _placeString = placeString;
    [self setNeedsDisplayInRect:placeNameRect];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGRect geoIconRect = CGRectMake(0, 0, 24.0, self.bounds.size.height);
    [self drawGeoIconInContext:context rect:geoIconRect];
    
    CGFloat margin = 8.0f;
    CGFloat placeXOrigin = geoIconRect.size.width + margin;
    placeNameRect = CGRectMake(placeXOrigin, 0, bounds.size.width - placeXOrigin, bounds.size.height);
    [self drawGeoPlaceInContext:context rect:placeNameRect];
}

- (void)drawGeoIconInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextSetRGBStrokeColor(context, 0.85, 0.90, 0.97, 1.0f);
    CGContextSetRGBFillColor(context, 0.87, 0.92, 0.99, 1.0);
    CGContextSetLineWidth(context, 0.5f);
    
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat rectWidth = rect.size.width / 2  - 4;
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, center.x - rectWidth, center.y);
    CGContextAddLineToPoint(context, center.x + rectWidth, center.y - rectWidth);
    CGContextAddLineToPoint(context, center.x, center.y + rectWidth);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawGeoPlaceInContext:(CGContextRef)context rect:(CGRect)rect
{
    if (!self.placeString) {
        return;
    }
    
    [self.placeString drawInRect:rect];
}

@end

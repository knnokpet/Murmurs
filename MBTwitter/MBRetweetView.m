//
//  MBRetweetView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBRetweetView.h"

@interface MBRetweetView()
{
    CGRect retweeterNameRect;
}

@end

@implementation MBRetweetView
#pragma mark - Initialize
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark Setter & Getter
- (void)setRetweeterString:(NSAttributedString *)retweeterString
{
    _retweeterString = retweeterString;
    
    [self setNeedsDisplayInRect:retweeterNameRect];
}

- (void)setUserLink:(MBMentionUserLink *)userLink
{
    _userLink = userLink;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
#pragma mark - Draw
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGFloat retweetIconHeight = bounds.size.height;
    if (retweetIconHeight > 12.0f) {
        retweetIconHeight = 12.0f;
    }
    CGRect retweetIconRect = CGRectMake(0, (bounds.size.height - retweetIconHeight) / 2, 24.0f, retweetIconHeight);
    [self drawRetweetIconInContext:context rect:retweetIconRect];
    
    CGFloat margin = 2.0f; /* 密参照すぎる */
    CGFloat nameXOrigin = retweetIconRect.size.width + margin;
    retweeterNameRect = CGRectMake(nameXOrigin, 0, bounds.size.width - nameXOrigin, bounds.size.height);
    [self drawRetweeterNameInContext:context rect:retweeterNameRect];
    
}

- (void)drawRetweetIconInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextSetRGBStrokeColor(context, 0.87, 0.92, 0.99, 0.5f);
    CGContextSetRGBFillColor(context, 0.87, 0.92, 0.99, 1.0);
    CGContextSetLineWidth(context, 1.0f);
    
    
    CGFloat betweenMargin = 1.0f;
    CGFloat arrowWidth = rect.size.width / 2 - betweenMargin * 2;
    CGFloat arrowHeight = rect.size.height / 2;
    CGFloat arrowLineWidth = arrowWidth / 3;
    
    CGPoint sentanLeftArrow = CGPointMake(rect.origin.x + (rect.size.width / 4) - betweenMargin, 0);
    CGPoint sentanRightArrow = CGPointMake(rect.origin.x + rect.size.width + betweenMargin - (rect.size.width / 4), rect.origin.y + rect.size.height);
    
    
    // left
    CGContextMoveToPoint(context, sentanLeftArrow.x, sentanLeftArrow.y);
    CGContextAddLineToPoint(context, rect.origin.x, sentanLeftArrow.y + arrowHeight);
    CGContextAddLineToPoint(context, rect.origin.x + arrowLineWidth, sentanLeftArrow.y + arrowHeight);
    CGContextAddArcToPoint(context, rect.origin.x + arrowLineWidth, sentanRightArrow.y, sentanRightArrow.x, sentanRightArrow.y, 2.0f);
    
    CGContextAddLineToPoint(context, sentanRightArrow.x - betweenMargin * 2, sentanRightArrow.y);
    CGContextAddLineToPoint(context, sentanRightArrow.x - arrowLineWidth - betweenMargin * 2 , sentanRightArrow.y - arrowLineWidth);
    
    CGContextAddArcToPoint(context,
                           rect.origin.x + arrowLineWidth * 2, sentanRightArrow.y - arrowLineWidth,
                           rect.origin.x + arrowLineWidth * 2, sentanLeftArrow.y + arrowHeight, 2.0f);
    CGContextAddLineToPoint(context, rect.origin.x + arrowLineWidth * 2, sentanLeftArrow.y + arrowHeight);
    CGContextAddLineToPoint(context, rect.origin.x + arrowWidth, sentanLeftArrow.y + arrowHeight);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    // right
    CGPoint boundsPoint = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
    CGContextMoveToPoint(context, sentanRightArrow.x, sentanRightArrow.y);
    CGContextAddLineToPoint(context, boundsPoint.x, boundsPoint.y - arrowHeight);
    CGContextAddLineToPoint(context, boundsPoint.x - arrowLineWidth, boundsPoint.y - arrowHeight);
    CGContextAddArcToPoint(context, boundsPoint.x - arrowLineWidth, sentanLeftArrow.y, sentanLeftArrow.x, sentanLeftArrow.y, 2.0f);
    
    CGContextAddLineToPoint(context, sentanLeftArrow.x + betweenMargin * 2, sentanLeftArrow.y);
    CGContextAddLineToPoint(context, sentanLeftArrow.x + arrowLineWidth + betweenMargin * 2, sentanLeftArrow.y + arrowLineWidth);
    
    CGContextAddArcToPoint(context, boundsPoint.x - arrowLineWidth * 2, sentanLeftArrow.y + arrowLineWidth, boundsPoint.x - arrowLineWidth * 2, boundsPoint.y - arrowHeight, 2.0f);
    CGContextAddLineToPoint(context, boundsPoint.x - arrowLineWidth * 2, sentanRightArrow.y - arrowHeight);
    CGContextAddLineToPoint(context, boundsPoint.x - arrowWidth, sentanRightArrow.y - arrowHeight);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawRetweeterNameInContext:(CGContextRef)context rect:(CGRect)rect
{
    if (!self.retweeterString) {
        return;
    }
    
    [self.retweeterString drawInRect:rect];
}

#pragma mark - Hit
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hittedView = [super hitTest:point withEvent:event];
    if (hittedView == self) {
        return hittedView;
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(retweetView:userLink:)]) {
        [_delegate retweetView:self userLink:self.userLink];
    }
}

@end

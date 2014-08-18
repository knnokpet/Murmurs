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
    CGRect retweetIconRect = CGRectMake(0, 0, 24.0f, bounds.size.height);
    [self drawRetweetIconInContext:context rect:retweetIconRect];
    
    CGFloat margin = 8.0f; /* 密参照すぎる */
    CGFloat nameXOrigin = retweetIconRect.size.width + margin;
    retweeterNameRect = CGRectMake(nameXOrigin, 0, bounds.size.width - nameXOrigin, bounds.size.height);
    [self drawRetweeterNameInContext:context rect:retweeterNameRect];
    
}

- (void)drawRetweetIconInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextSetRGBFillColor(context, 0, 255, 122, 1.0);
    CGContextFillRect(context, rect);
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

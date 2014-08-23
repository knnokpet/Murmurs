//
//  MBMagnifierRangeView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMagnifierRangeView.h"

@interface MBMagnifierRangeView()

@property (nonatomic, weak) UIView *viewToShow;
@property (nonatomic, weak) UIView *viewForShow;
@property (nonatomic, assign) CGPoint touchPoint;

@property (nonatomic) UIImage *maskImage;

@end

@implementation MBMagnifierRangeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MagnifierRangeMask@2x" ofType:@"png"];
        UIImage *maskImage = [[UIImage alloc] initWithContentsOfFile:path];
        self.maskImage = maskImage;
    }
    return self;
}

- (void)setTouchPoint:(CGPoint)touchPoint
{
    _touchPoint = touchPoint;
    self.center = CGPointMake(touchPoint.x, touchPoint.y - self.maskImage.size.height * 1.5);
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point
{
    [self showInView:view forView:view atPoint:point];
}

- (void)showInView:(UIView *)inView forView:(UIView *)forView atPoint:(CGPoint)point
{
    self.frame = CGRectMake(0.0f, 0.0f, self.maskImage.size.width, self.maskImage.size.height);
    
    self.viewToShow = inView;
    self.viewForShow = forView;
    self.touchPoint = point;
    
    [inView addSubview:self];
    
    CGRect frame = self.frame;
    CGPoint center = self.center;
    
    CGRect startFrame = self.frame;
    startFrame.size = CGSizeZero;
    self.frame = startFrame;
    
    CGPoint startPoint = self.center;
    startPoint.y += frame.size.height;
    self.center = startPoint;
    
    [UIView animateWithDuration:0.15f delay:0.0f options:kNilOptions animations:^{
        self.frame = frame;
        self.center = center;
    }completion:NULL];
}

- (void)hideView
{
    CGRect bounds = self.bounds;
    bounds.size = CGSizeZero;
    
    CGPoint endPoint = self.touchPoint;
    
    [UIView animateWithDuration:0.15f delay:0.0f options:kNilOptions animations:^{
        self.frame = bounds;
        self.center = endPoint;
    }completion:^(BOOL finished) {
        self.viewToShow = nil;
        [self removeFromSuperview];
    }];
}

- (void)moveToPoint:(CGPoint)point
{
    [self setTouchPoint:point];
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGImageRef maskRef = self.maskImage.CGImage;
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, bounds, maskRef);
    CGContextFillRect(context, bounds);
    CGContextScaleCTM(context, 1.2, 1.2);
    
    CGContextTranslateCTM(context, 1 * (self.frame.size.width * 0.5), 1 * (self.frame.size.height * 0.5));
    CGContextTranslateCTM(context, -1 * (self.touchPoint.x), -1 * (self.touchPoint.y));
    
    if ([self.viewForShow respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self.viewForShow drawViewHierarchyInRect:self.viewForShow.bounds afterScreenUpdates:NO];
    } else {
        [self.viewForShow.layer renderInContext:context];
    }
    
    CGContextRestoreGState(context);
}


@end

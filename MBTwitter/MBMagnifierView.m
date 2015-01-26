//
//  MBMagnifierView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMagnifierView.h"

@interface MBMagnifierView()
{
    CGImageRef maskImageRef;
}

@property (nonatomic, weak) UIView *viewToShow;
@property (nonatomic, weak) UIView *viewForShow;
@property (nonatomic, assign) CGPoint touchPoint;

@property (nonatomic) UIImage *maskImage;
@property (nonatomic) UIImage *loupeLowImage;
@property (nonatomic) UIImage *loupeHighimage;

@end

@implementation MBMagnifierView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MagnifierMask-withWhite@2x" ofType:@"png"];
        UIImage *maskImage = [UIImage imageNamed:path];
        self.maskImage = maskImage;
        CGImageRef imageRef = self.maskImage.CGImage;
        CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), CGImageGetBitsPerComponent(imageRef), CGImageGetBitsPerPixel(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetDataProvider(imageRef), NULL, false);
        maskImageRef = maskRef;
        
        path = [[NSBundle mainBundle] pathForResource:@"Magnifier-low@2x" ofType:@"png"];
        UIImage *loupeLowImage = [UIImage imageNamed:path];
        self.loupeLowImage = loupeLowImage;
        
        path = [[NSBundle mainBundle] pathForResource:@"Magnifier-high@2x" ofType:@"png"];
        UIImage *loupeHighImage = [UIImage imageNamed:path];
        self.loupeHighimage = loupeHighImage;
        
    }
    return self;
}

- (void)dealloc
{
    if (maskImageRef) {
        CFRelease(maskImageRef);
    }
}

- (void)setTouchPoint:(CGPoint)touchPoint
{
    _touchPoint = touchPoint;
    self.center = CGPointMake(touchPoint.x, touchPoint.y - self.maskImage.size.height / 2);
}


- (void)showInView:(UIView *)view atPoint:(CGPoint)point
{
    [self showInView:view forView:view atPoint:point];
}

- (void)showInView:(UIView *)view forView:(UIView *)forView atPoint:(CGPoint)point
{
    self.frame = CGRectMake(0.f, 0.f, self.maskImage.size.width, self.maskImage.size.height);
    
    self.viewToShow = view;
    self.viewForShow = forView;
    self.touchPoint = point;
    
    [view addSubview:self];
    
    CGRect frame = self.frame;
    CGPoint center = self.center;
    
    CGRect startFrame = self.frame;
    startFrame.size = CGSizeZero;
    self.frame = startFrame;
    
    CGPoint startPoint = self.center;
    startPoint.y += frame.size.height;
    self.center = startPoint;
    
    [UIView animateWithDuration:0.1f delay:0.0 options:kNilOptions animations:^{
        self.frame = frame;
        self.center = center;
    }completion:NULL];
}

- (void)hide
{
    CGRect bounds = self.bounds;
    bounds.size = CGSizeZero;
    
    CGPoint endPoint = self.touchPoint;
    
    [UIView animateWithDuration:0.1f delay:0.0 options:kNilOptions animations:^{
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGImageRef maskRef = maskImageRef;
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, bounds, maskRef);
    CGContextFillRect(context, bounds);
    CGContextScaleCTM(context, 1.2, 1.2);
    
    CGContextTranslateCTM(context, 1 * (self.frame.size.width * 0.5), 1 * (self.frame.size.height * 0.5));
    CGContextTranslateCTM(context, -1 *(self.touchPoint.x), -1 * (self.touchPoint.y));
    
    if ([self.viewForShow respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self.viewForShow drawViewHierarchyInRect:self.viewForShow.bounds afterScreenUpdates:NO];
    } else {
        [self.viewForShow.layer renderInContext:context];
    }
    
    CGContextRestoreGState(context);
    
    //[self.loupeHighimage drawInRect:bounds];
}


- (UIImage *)screenShot
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
    }
    return nil;
}


@end

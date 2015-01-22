//
//  MBGeoPinView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/21.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBGeoPinView.h"

@interface MBDotView : UIView

@property (nonatomic) UIColor *dotColor;

@end


@implementation MBDotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef harfAlphaColorRef = CGColorCreateCopyWithAlpha(self.dotColor.CGColor, 0.5f);
    CGContextSetStrokeColorWithColor(context, harfAlphaColorRef);
    CGContextSetFillColorWithColor(context, self.dotColor.CGColor);
    
    CGContextAddEllipseInRect(context, rect);
    CGColorRelease(harfAlphaColorRef);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGSize whiteEllipseSize = CGSizeMake(rect.size.width / 4, rect.size.height / 4);
    CGRect whiteEllipseRect = CGRectMake(rect.origin.x + whiteEllipseSize.width, rect.origin.y + whiteEllipseSize.height, whiteEllipseSize.width, whiteEllipseSize.height);
    CGContextAddEllipseInRect(context, whiteEllipseRect);
    
}

@end



@interface MBPinView : UIView

@end


@implementation MBPinView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat r,g,b;
    r = 200 / 255;
    g = 200 / 255;
    b = 200 / 255;
    CGContextSetRGBStrokeColor(context, r, g, b, 0.5f);
    CGContextSetRGBFillColor(context, r, g, b, 1.0f);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end





@interface MBGeoPinView()

@property (nonatomic, readonly) UIImageView *dotView;
@property (nonatomic, readonly) UIImageView *pinView;
@property (nonatomic, readonly) UIImageView *pinHoleView;

@end

@implementation MBGeoPinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        // Dot
        CGFloat radius = 6.0f;
        _dotView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - radius, 0, radius * 2, radius * 2)];

        self.dotView.image = [UIImage imageNamed:@"Dot"];
        [self addSubview:self.dotView];
        
        // Pint
        CGFloat pinWidth = 1.0f;
        CGFloat pinOriginY = self.dotView.frame.origin.y + self.dotView.frame.size.height - 1;
        CGRect pinRect = CGRectMake(self.frame.size.width / 2 - pinWidth / 2, pinOriginY, pinWidth, self.frame.size.height - pinOriginY);
        _pinView = [[UIImageView alloc] initWithFrame:pinRect];
        self.pinView.image = [UIImage imageNamed:@"Pin"];
        [self insertSubview:self.pinView belowSubview:self.dotView];
        
        // PinHole
        CGFloat pinHoleWidth = 2.0f;
        CGFloat pinHoleHeight = 1.0f;
        _pinHoleView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - pinHoleWidth / 2, self.frame.size.height - pinHoleHeight, pinHoleWidth, pinHoleHeight)];
        self.pinHoleView.image = [UIImage imageNamed:@"PinHole"];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
}*/

- (void)showPinHoleView:(BOOL)shows
{
    if (shows) {
        [self addSubview:self.pinHoleView];
    } else {
        [self.pinHoleView removeFromSuperview];
    }
    
}

- (void)boundingAnimateDotWithCompletion:(CompletionHandler)completion
{
    [self showPinHoleView:YES];
    
    CGRect endRect = self.dotView.frame;
    CGRect boundingRect = endRect;
    boundingRect.origin.y = boundingRect.origin.y + 4.0f;
    [UIView animateWithDuration:0.1f animations:^{
        self.dotView.frame = boundingRect;
        self.dotView.frame = endRect;
        
    }completion:^(BOOL finished) {
        completion();
    }];
}

- (void)scallingAnimateDotWithCompletion:(CompletionHandler)completion
{
    [UIView animateWithDuration:0.1f animations:^{
        self.dotView.transform = CGAffineTransformMakeScale(0.5, 2.0);
        self.dotView.transform = CGAffineTransformMakeScale(0, 0);
        self.pinHoleView.transform = CGAffineTransformMakeScale(0, 0);
    }completion:^(BOOL finished) {
        
        completion();
    }];
}

- (void)contractView
{
    CGFloat endOriginY = self.pinView.frame.origin.y + self.pinView.frame.size.height;
    
    CGRect dotEndRect = self.dotView.frame;
    dotEndRect.origin.y = endOriginY - dotEndRect.size.height;
    self.dotView.frame = dotEndRect;
    
    CGRect pinRect = self.pinView.frame;
    pinRect.origin.y = endOriginY;
    pinRect.size.height = 0.0f;
    self.pinView.frame = pinRect;
}

@end

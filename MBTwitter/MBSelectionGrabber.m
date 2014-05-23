//
//  MBSelectionGrabber.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSelectionGrabber.h"

@interface MBSelectionGrabberDot : UIView

@property (nonatomic) UIColor *dotColor;
@property (nonatomic) UIBezierPath *path;

@end

@implementation MBSelectionGrabberDot

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.dotColor set];
    [self.path fill];
}

@end



@interface MBSelectionGrabber()

@property (nonatomic) UIView *caretView;
@property (nonatomic) MBSelectionGrabberDot *dotView;

@end

@implementation MBSelectionGrabber

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.caretView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 0.0f)];
        self.caretView.backgroundColor = self.caretColor;
        [self addSubview:self.caretView];
        
        self.dotView = [[MBSelectionGrabberDot alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
        [self.dotView setDotColor:self.dotColor];
        [self addSubview:self.dotView];
    }
    return self;
}

- (void)setCaretColor:(UIColor *)caretColor
{
    _caretColor = caretColor;
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect caretFrame = self.caretView.frame;
    caretFrame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(caretFrame)) / 2;
    caretFrame.size.height = CGRectGetHeight(self.bounds);
    self.caretView.frame = caretFrame;
    
    CGRect dotFrame = self.dotView.frame;
    if (self.dotMetric == MBSelectionGrabberDotMetricTop) {
        dotFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(dotFrame)) / 2, - CGRectGetHeight(dotFrame));
    } else {
        dotFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(dotFrame)) / 2, CGRectGetHeight(self.bounds));
    }
    self.dotView.frame = dotFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

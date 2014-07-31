//
//  MBGradientMaskView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBGradientMaskView.h"

@implementation MBGradientMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setStartGradientPoint:(CGPoint)startGradientPoint
{
    _startGradientPoint = startGradientPoint;
}

- (void)setEndGradientPoint:(CGPoint)endGradientPoint
{
    _endGradientPoint = endGradientPoint;
}

- (void)maskGradient
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = self.startGradientPoint;
    gradientLayer.endPoint = self.endGradientPoint;
    self.layer.mask = gradientLayer;
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

//
//  MBRoundButton.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBRoundButton.h"

@implementation MBRoundButton

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
    self.layer.cornerRadius = 2.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = self.tintColor.CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
    UIColor *tintColor = self.tintColor;
    CGRect bounds = self.bounds;
    
    UIBezierPath *roundBezier = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:6.0f];
    roundBezier.lineWidth = 2.0f;
    [tintColor setStroke];
    [roundBezier stroke];
}
*/

@end

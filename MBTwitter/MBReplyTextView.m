//
//  MBReplyTextView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/02.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBReplyTextView.h"

@implementation MBReplyTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textColor = [UIColor darkGrayColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);
    CGContextSetLineWidth(context, 0.5);
    CGPoint bottomPoint = CGPointMake(0, self.frame.size.height);
    CGContextMoveToPoint(context, 0, bottomPoint.y);
    CGContextAddLineToPoint(context, self.frame.size.width, bottomPoint.y);
    CGContextStrokePath(context);
}


@end

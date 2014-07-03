//
//  MBTimelineActionContainerView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineActionContainerView.h"

@implementation MBTimelineActionContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 8.0f;
        self.clipsToBounds = true;
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    /*
    CGRect frame = self.bounds;
    UIBezierPath *bezierpath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:4.0f];
    [[UIColor clearColor] setStroke];
    [bezierpath stroke];
    
    //[self.backgroundColor setFill];
    //[bezierpath fill];
    */
}


@end

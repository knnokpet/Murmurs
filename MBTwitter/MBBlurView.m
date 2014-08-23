//
//  MBBlurView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBBlurView.h"

@implementation MBBlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)updateBlurView
{
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    
    [self.backgroundView drawViewHierarchyInRect:self.backgroundView.bounds afterScreenUpdates:NO];
    //[self.backgroundView drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImage *blurdImage = [backgroundImage applyLightEffect];
    
    UIGraphicsEndImageContext();
    
    [blurdImage drawInRect:self.bounds];
}


@end

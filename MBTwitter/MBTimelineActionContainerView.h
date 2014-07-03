//
//  MBTimelineActionContainerView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//


#import "MBBlurView.h"

@interface MBTimelineActionContainerView : MBBlurView

@property (nonatomic, readonly) UIColor *color;
- (void)setColor:(UIColor *)color;

@end

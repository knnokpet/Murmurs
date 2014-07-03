//
//  MBTimelineActionArrowView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBBlurView.h"

@interface MBTimelineActionArrowView : MBBlurView

@property (nonatomic, readonly, assign) BOOL isUpper;
@property (nonatomic, readonly) UIColor *color;/*unused*/

- (instancetype)initWithFrame:(CGRect)frame isUpperArrow:(BOOL)isUpper;/* unused */
- (void)setColor:(UIColor *)color;/*unused*/
- (void)setIsUpper:(BOOL)isUpper;

@end

//
//  MBGradientMaskView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBGradientMaskView : UIView

@property (nonatomic, readonly) CGPoint startGradientPoint;
@property (nonatomic, readonly) CGPoint endGradientPoint;
- (void)setStartGradientPoint:(CGPoint)startGradientPoint;
- (void)setEndGradientPoint:(CGPoint)endGradientPoint;

- (void)maskGradient;

@end

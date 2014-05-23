//
//  MBSelectionGrabber.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MBSelectionGrabberDotMetrics) {
    MBSelectionGrabberDotMetricTop,
    MBSelectionGrabberDotMetricBottom
};

@interface MBSelectionGrabber : UIView

@property (nonatomic) MBSelectionGrabberDotMetrics dotMetric;
@property (nonatomic, readonly) UIColor *caretColor;
@property (nonatomic, readonly) UIColor *dotColor;
- (void)setCaretColor:(UIColor *)caretColor;
- (void)setDotColor:(UIColor *)dotColor;

@end

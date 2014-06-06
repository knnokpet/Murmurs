//
//  MBMagnifierView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MBMagnifierView : UIView

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;
- (void)showInView:(UIView *)view forView:(UIView *)forView atPoint:(CGPoint)point;
- (void)moveToPoint:(CGPoint)point;
- (void)hide;

@end

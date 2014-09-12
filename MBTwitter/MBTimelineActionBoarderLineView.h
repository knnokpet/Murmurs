//
//  MBTimelineActionBoarderLineView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBTimelineActionBoarderLineView : UIView

@property (nonatomic, readonly) UIColor *defaultColor;
@property (nonatomic, readonly) UIColor *selectedColor;
@property (nonatomic, readonly, assign) BOOL selected;
- (void)setDefaultColor:(UIColor *)defaultColor;
- (void)setSelectedColor:(UIColor *)selectedColor;
- (void)setSelected:(BOOL)selected;

@end

//
//  MBTimelineActionBoarderLineView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineActionBoarderLineView.h"

@implementation MBTimelineActionBoarderLineView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.defaultColor = [UIColor clearColor];
    self.selectedColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.selected = NO;
}

- (void)setDefaultColor:(UIColor *)defaultColor
{
    _defaultColor = defaultColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    self.backgroundColor = (selected) ? self.selectedColor : self.defaultColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

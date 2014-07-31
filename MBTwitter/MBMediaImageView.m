//
//  MBMediaImageView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMediaImageView.h"

@implementation MBMediaImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setMediaIDStr:(NSString *)mediaIDStr
{
    _mediaIDStr = mediaIDStr;
}

- (void)setMediaHTTPURLString:(NSString *)mediaHTTPURLString
{
    _mediaHTTPURLString = mediaHTTPURLString;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *touchedView = [super hitTest:point withEvent:event];
    if (touchedView == self) {
        return touchedView;
    }
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchedPoint = [touch locationInView:self];
    
    if ([_delegate respondsToSelector:@selector(didTapImageView:mediaIDStr:urlString:touchedPoint:rect:)]) {
        [_delegate didTapImageView:self mediaIDStr:self.mediaIDStr urlString:self.mediaHTTPURLString touchedPoint:touchedPoint rect:self.frame];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

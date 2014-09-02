//
//  MBAvatorImageView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAvatorImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface MBAvatorImageView()

@property (nonatomic) UIView *selectingCoverView;

@end

@implementation MBAvatorImageView
#pragma mark - Initialize
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1.0];
}

#pragma mark - Setter & Getter
- (void)setUserID:(NSNumber *)userID
{
    _userID = userID;
}

- (void)setUserIDStr:(NSString *)userIDStr
{
    _userIDStr = userIDStr;
}

- (void)setIsSelected:(BOOL)isSelected withAnimated:(BOOL)animated
{
    _isSelected = isSelected;
    
    [self changeViewStateForSelectingWithAnimated:animated];
}

- (void)setAvatorImage:(UIImage *)avatorImage
{
    _avatorImage = avatorImage;
    
    self.backgroundColor = (avatorImage)? [UIColor clearColor] : [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1.0];
    self.image = avatorImage;
}

#pragma mark - Instance Methods
- (void)changeViewStateForSelectingWithAnimated:(BOOL)animated
{
    CGFloat duration = (animated) ? 0.5f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        /* layer のバックグラウンドを変更＆ opaque 調整で出来るらしいんだけど、出来ないから view を重ねる */
        if (self.isSelected) {
            self.selectingCoverView = [[UIView alloc] initWithFrame:self.bounds];
            self.selectingCoverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
            self.selectingCoverView.layer.cornerRadius = self.layer.cornerRadius;
            [self addSubview:self.selectingCoverView];
        } else {
            self.selectingCoverView.backgroundColor = [UIColor clearColor];
        }
    }completion:^ (BOOL finished) {
        if (self.selectingCoverView.superview && !self.isSelected) {
            [self.selectingCoverView removeFromSuperview];
        }
    }];
    
    
}

#pragma mark - UIView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *touchedView = [super hitTest:point withEvent:event];
    if (self == touchedView) {
        return touchedView;
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(imageViewDidClick:userID:userIDStr:)]) {
        [_delegate imageViewDidClick:self userID:self.userID userIDStr:self.userIDStr];
    }
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


@end

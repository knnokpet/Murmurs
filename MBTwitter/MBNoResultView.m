//
//  MBNoResultView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/15.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import "MBNoResultView.h"

@interface MBNoResultView()
@property (nonatomic, readonly) UILabel *resultLabel;

@end

@implementation MBNoResultView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    CGFloat r, g, b, a;
    r = g = b = 0.98;
    a = 1.0;
    UIColor *backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    self.backgroundColor = backgroundColor;
    
    _resultLabel = [[UILabel alloc] init];
    self.resultLabel.font = [UIFont systemFontOfSize:19.0];
    a  = 0.5;
    self.resultLabel.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    self.resultLabel.shadowColor = [UIColor darkGrayColor];
    self.resultLabel.shadowOffset = CGSizeMake(0, -1.0);
    
    [self configureReloadButton];
}

- (void)configureReloadButton
{
    _reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setTitle:NSLocalizedString(@"Reload", nil) forState:UIControlStateNormal];
    [self.reloadButton setTitle:NSLocalizedString(@"Reloading...", nil) forState:UIControlStateDisabled];
    [self.reloadButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    
    _requireReloadButton = YES;
}

- (void)setNoResultText:(NSString *)noResultText
{
    _noResultText = noResultText;
    self.resultLabel.text = noResultText;
    
    [self layoutLabelAndButton];
}

- (void)layoutLabelAndButton
{
    [self.resultLabel sizeToFit];
    [self.reloadButton sizeToFit];
    
    CGFloat margin = 16.0f;
    self.resultLabel.center = self.center;
    CGRect frame = self.resultLabel.frame;
    frame.origin.y -= margin;
    self.resultLabel.frame = frame;
    [self addSubview:self.resultLabel];
    
    self.reloadButton.center = self.center;
    frame = self.reloadButton.frame;
    frame.origin.y += margin;
    self.reloadButton.frame = frame;
    
    if (self.requireReloadButton) {
        [self addSubview:self.reloadButton];
    } else {
        if (self.reloadButton.superview) {
            [self.reloadButton removeFromSuperview];
        }
    }
    
}

- (void)setIsReloading:(BOOL)isReloading withAnimated:(BOOL)animated
{
    _isReloading = isReloading;
    CGFloat duration = (animated) ? 0.3f : 0;
    
    [UIView animateWithDuration:duration animations:^{
        
        self.reloadButton.enabled = (isReloading) ? NO : YES;
        
        [self layoutLabelAndButton];
    }];
    
}

- (void)setRequireReloadButton:(BOOL)requireReloadButton
{
    _requireReloadButton = requireReloadButton;
    [self layoutLabelAndButton];
}

@end

//
//  MBNavigationControllerTitleView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBNavigationControllerTitleView.h"

@interface MBNavigationControllerTitleView()
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *screenNameLabel;
@property (nonatomic, readonly) UIImageView *logoImageView;

@end

@implementation MBNavigationControllerTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        // Initialization code
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _screenNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.titleLabel];
        
        self.screenNameLabel.font = [UIFont systemFontOfSize:12.0f];
        self.screenNameLabel.textColor = [UIColor grayColor];
        [self addSubview:self.screenNameLabel];
        
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bird_blue_32"]];
        [self addSubview:self.logoImageView];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", screenName];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    [self.screenNameLabel sizeToFit];
    
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    CGFloat titleScreenMargin = 0.0f;
    
    CGRect titleRect = self.titleLabel.frame;
    titleRect.origin = CGPointMake(center.x - titleRect.size.width / 2, center.y - titleRect.size.height - titleScreenMargin / 2 + 4.0);
    self.titleLabel.frame = titleRect;
    
    
    CGFloat screenNameLogoWidth = self.screenNameLabel.frame.size.width + self.logoImageView.frame.size.width + self.logoImageView.frame.size.width * 0.3;
    
    CGRect logoRect = self.logoImageView.frame;
    logoRect.origin = CGPointMake(center.x - screenNameLogoWidth / 2, titleRect.origin.y + titleRect.size.height);
    self.logoImageView.frame = logoRect;
    
    CGRect screenRect = self.screenNameLabel.frame;
    screenRect.origin = CGPointMake(logoRect.origin.x + logoRect.size.width + logoRect.size.width  * 0.3, logoRect.origin.y + logoRect.size.height / 2 - screenRect.size.height / 2);
    self.screenNameLabel.frame = screenRect;
    
    
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

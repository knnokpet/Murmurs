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
        [self addSubview:self.titleLabel];
        
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    
    CGRect titleRect = self.titleLabel.frame;
    titleRect.origin = CGPointMake(center.x - titleRect.size.width / 2, center.y - titleRect.size.height / 2 + 2.0f);
    self.titleLabel.frame = titleRect;
    
    
    CGRect logoRect = self.logoImageView.frame;
    logoRect.origin = CGPointMake(center.x - logoRect.size.width / 2, titleRect.origin.y - logoRect.size.height);
    self.logoImageView.frame = logoRect;
    
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

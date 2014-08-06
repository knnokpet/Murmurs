//
//  MBTitleWithImageButton.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTitleWithImageButton.h"

@implementation MBTitleWithImageButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setButtonTitle:title];
        [self setButtonImage:image];
    }
    
    return self;
}

- (void)setButtonImage:(UIImage *)buttonImage
{
    _buttonImage = buttonImage;
    
    [self setImage:buttonImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setButtonTitle:(NSString *)buttonTitle
{
    _buttonTitle = buttonTitle;
    
    [self setTitle:buttonTitle forState:UIControlStateNormal];
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    
    CGRect imageViewRect = self.imageView.frame;
    imageViewRect.origin = CGPointMake(center.x - imageViewRect.size.width / 2, center.y - imageViewRect.size.height);
    self.imageView.frame = imageViewRect;
    
    [self.titleLabel sizeToFit];
    CGRect titleLabelRect = self.titleLabel.frame;
    titleLabelRect.origin = CGPointMake(center.x - titleLabelRect.size.width / 2, center.y);
    self.titleLabel.frame = titleLabelRect;
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

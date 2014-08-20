//
//  MBLabelImageHeaderView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/19.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLabelImageHeaderView.h"

@implementation MBLabelImageHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.imageView.layer.cornerRadius = 2.0f;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.shouldRasterize = YES;
    [self addSubview:self.imageView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.font = [UIFont boldSystemFontOfSize:14.0f];
    [self addSubview:self.label];
    
    CGFloat r, g, b, a;
    r = 0.98;
    g = 0.98;
    b = 1.0;
    a = 1.0;
    self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    [self setNeedsLayout];
}

- (void)setLabelString:(NSString *)labelString
{
    _labelString = labelString;
    self.label.text = labelString;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageViewRect = self.imageView.frame;
    imageViewRect.origin = CGPointMake(14.0f, 4.0f);
    self.imageView.frame = imageViewRect;
    
    [self.label sizeToFit];
    CGRect labelRect = self.label.frame;
    labelRect.origin = CGPointMake(imageViewRect.origin.x + imageViewRect.size.width + 4.0f, imageViewRect.origin.y + (imageViewRect.size.height - labelRect.size.height) / 2);
    self.label.frame = labelRect;
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

//
//  MBUsersTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsersTableViewCell.h"

@implementation MBUsersTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self common];
}

- (void)common
{    
    self.avatorImageView.backgroundColor = [UIColor clearColor];
    self.avatorImageView.layer.cornerRadius = 4.0f;
    self.avatorImageView.layer.masksToBounds = NO;
    self.avatorImageView.layer.shouldRasterize = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    if (screenName.length > 0) {
        NSString *screenNameWithAt = [NSString stringWithFormat:@"@%@", screenName];
        self.screenNameLabel.text = screenNameWithAt;
    }
}

- (void)addAvatorImage:(UIImage *)image
{
    if (!image) {
        return;
    }

    self.avatorImageView.alpha = 0;
    self.avatorImageView.image = image;
    [UIView animateWithDuration:0.3f animations:^{
        self.avatorImageView.alpha = 1.0f;
    }];
}

- (CGSize)avatorImageViewSize
{
    CGSize avatorImageSize = CGSizeMake(self.avatorImageView.bounds.size.width, self.avatorImageView.bounds.size.height);
    return avatorImageSize;
}

- (CGFloat)avatorImageViewRadius
{
    CGFloat radius = self.avatorImageView.layer.cornerRadius;
    return radius;
}

@end

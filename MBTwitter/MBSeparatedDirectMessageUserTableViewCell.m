//
//  MBSeparatedDirectMessageUserTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSeparatedDirectMessageUserTableViewCell.h"
#import "MBAvatorImageView.h"
#import "MBCharacterScreenNameView.h"

@implementation MBSeparatedDirectMessageUserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self common];
}

- (void)common
{
    self.avatorImageView.backgroundColor = [UIColor clearColor];
    self.avatorImageView.layer.masksToBounds = NO;
    self.avatorImageView.layer.shouldRasterize = YES;
    self.avatorImageView.layer.cornerRadius = 4.0f;
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateString:(NSString *)dateString
{
    _dateString = dateString;
    
    self.dateLabel.text = dateString;
}

- (void)setCharaScreenString:(NSAttributedString *)charaScreenString
{
    _charaScreenString = charaScreenString;
    self.characterScreenNameView.characterScreenString = charaScreenString;
}

- (void)setSubtitleString:(NSString *)subtitleString
{
    _subtitleString = subtitleString;
    self.subtitleLabel.text = subtitleString;
}

- (void)setUserIDStr:(NSString *)userIDStr
{
    _userIDStr = userIDStr;
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
    CGSize viewSize = CGSizeMake(self.avatorImageView.bounds.size.width, self.avatorImageView.bounds.size.height);
    return viewSize;
}

- (CGFloat)avatorImageViewRadius
{
    CGFloat radius = self.avatorImageView.layer.cornerRadius;
    return radius;
}

@end

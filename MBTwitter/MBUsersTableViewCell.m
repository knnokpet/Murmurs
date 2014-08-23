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

@end

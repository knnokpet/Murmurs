//
//  MBFollowRequestTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBFollowRequestTableViewCell.h"
#import "MBAvatorImageView.h"

@implementation MBFollowRequestTableViewCell

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

- (void)setUserID:(NSNumber *)userID
{
    _userID = userID;
}

- (void)setUserIDStr:(NSString *)userIDStr
{
    _userIDStr = userIDStr;
}

- (void)setCharacterName:(NSString *)characterName
{
    _characterName = characterName;
    self.characterNameLabel.text = characterName;
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    if (screenName.length > 0) {
        NSString *screenAt = [NSString stringWithFormat:@"@%@", screenName];
        self.screenNameLabel.text = screenAt;
    }
}

@end

//
//  MBDetailTweetUserTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetUserTableViewCell.h"

@implementation MBDetailTweetUserTableViewCell

- (void)awakeFromNib
{
    self.avatorImageView.layer.cornerRadius = 4.0f;
    self.avatorImageView.layer.masksToBounds = YES;
    
    UIEdgeInsets separatorInset = self.separatorInset;
    separatorInset.left = self.bounds.size.width;
    separatorInset.right = self.bounds.size.width;
    separatorInset = UIEdgeInsetsZero;
    //self.separatorInset = separatorInset;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    if (0 < screenName.length) {
        NSString *nameWithAtmark = [NSString stringWithFormat:@"@%@", screenName];
        self.screenNameLabel.text = nameWithAtmark;
    }
}

- (void)setIsVerified:(BOOL)isVerified
{
    _isVerified = isVerified;
    if (!isVerified) {
        [self.verifiedBadgeImageView removeFromSuperview];
    }
}

@end

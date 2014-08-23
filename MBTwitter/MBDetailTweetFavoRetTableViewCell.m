//
//  MBDetailTweetFavoRetTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/20.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetFavoRetTableViewCell.h"

@implementation MBDetailTweetFavoRetTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)removeFavoriteButton
{
    if (self.favoriteButton.superview) {
        [self.favoriteButton removeFromSuperview];
        self.favoriteButton = nil;
    }
}

- (void)removeRetweetButton
{
    if (self.retweetButton.superview) {
        [self.retweetButton removeFromSuperview];
        self.retweetButton = nil;
    }
}

@end

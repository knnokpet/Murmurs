//
//  MBDetailTweetFavoriteRetweetTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/06.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetFavoriteRetweetTableViewCell.h"

@implementation MBDetailTweetFavoriteRetweetTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self commonInit];
}

- (void)commonInit
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsRetweeted:(BOOL)isRetweeted
{
    _isRetweeted = isRetweeted;
    
    UIImage *retweetImage = [UIImage imageNamed:@"Retweet-Line"];
    if (isRetweeted) {
        retweetImage = [UIImage imageNamed:@"Retweet-Green"];
    }
    self.retweetImageView.image = retweetImage;
}

- (void)setIsFavorited:(BOOL)isFavorited
{
    _isFavorited = isFavorited;
    
    UIImage *favoriteImage = [UIImage imageNamed:@"Star-Line"];
    if (isFavorited) {
        favoriteImage = [UIImage imageNamed:@"Star-Orange"];
    }
    self.favoriteImageView.image = favoriteImage;
}

- (void)setRetweetCount:(NSInteger)retweetCount
{
    _retweetCount = retweetCount;
    
    UIColor *titleColor = [UIColor lightGrayColor];
    if (retweetCount > 0) {
        titleColor = [UIColor blackColor];
    } else {
        retweetCount = 0;
    }
    self.retweetTitleLabel.text = [NSString stringWithFormat:@"%ld", (long)retweetCount];
    self.retweetTitleLabel.textColor = titleColor;
}

- (void)setFavoriteCount:(NSInteger)favoriteCount
{
    _favoriteCount = favoriteCount;
    
    UIColor *titleColor = [UIColor lightGrayColor];
    if (favoriteCount > 0) {
        titleColor = [UIColor blackColor];
    } else {
        favoriteCount = 0;
    }
    self.favoriteTitleLabel.text = [NSString stringWithFormat:@"%ld", (long)favoriteCount];
    self.favoriteTitleLabel.textColor = titleColor;
}

@end

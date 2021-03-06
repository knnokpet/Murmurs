//
//  MBDetailTweetTextTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetTextTableViewCell.h"
#import "MBTweetTextView.h"
#import "MBFavoriteView.h"
#import "MBTimelineImageContainerView.h"

@implementation MBDetailTweetTextTableViewCell

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

#pragma mark -
#pragma mark Instance Methods
- (void)removeRetweetView
{
    if (self.retweeterView.superview) {
        [self.retweeterView removeFromSuperview];
        self.retweeterView = nil;
    }
}

- (void)removeImageContainerView
{
    if (self.imageContainerView.superview) {
        [self.imageContainerView removeFromSuperview];
        self.imageContainerView = nil;
    }
}

@end

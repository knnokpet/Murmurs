//
//  MBDetailTweetTextTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetTextTableViewCell.h"
#import "MBTweetTextView.h"

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
    if (self.retweetView.superview) {
        [self.retweetView removeFromSuperview];
        self.retweetView = nil;
    }
}

@end

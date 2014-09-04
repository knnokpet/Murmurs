//
//  MBSendMessageTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSendMessageTableViewCell.h"
#import "MBTweetTextView.h"
#import "MBMessageView.h"

@implementation MBSendMessageTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.tweetTextView.backgroundColor = [UIColor clearColor];
}

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

- (void)setTweetViewRect:(CGRect)tweetViewRect
{
    _tweetViewRect = tweetViewRect;
    
    CGFloat tweetViewWidth = tweetViewRect.size.width + self.tweetTextViewLeftSpaceConstraint.constant + self.tweetTextViewRightSpaceConstraint.constant;
    
    CGFloat defaultMessageViewLeftSpace = 60.0f;
    CGFloat maxixmumMessageWidth = self.bounds.size.width - (self.messageView.frame.origin.x + defaultMessageViewLeftSpace);
    if (tweetViewWidth < maxixmumMessageWidth) {
        self.messageViewLeftSpaceConstraint.constant = self.bounds.size.width - (self.messageView.frame.origin.x) - tweetViewWidth;
    } else {
        self.messageViewLeftSpaceConstraint.constant = defaultMessageViewLeftSpace;
    }
    [self layoutIfNeeded];
}

@end

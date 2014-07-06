//
//  MBSendMessageTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

@class MBAvatorImageView;
@class MBTweetTextView;
@class MBMessageView;
#import <UIKit/UIKit.h>

@interface MBSendMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MBTweetTextView *tweetTextView;
@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet MBMessageView *messageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetTextViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetTextViewLeftSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetTextViewRightSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewLeftSpaceConstraint;

@property (nonatomic, readonly) CGRect tweetViewRect;
- (void)setTweetViewRect:(CGRect)tweetViewRect;

@end

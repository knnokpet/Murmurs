//
//  MBTweetViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAvatorImageView.h"
#import "MBTweetTextView.h"

@class MBTweetTextView;
@interface MBTweetViewCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *chacacterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet MBTweetTextView *retweetView;

@property (weak, nonatomic) IBOutlet MBTweetTextView *dateView;
@property (weak, nonatomic) IBOutlet MBTweetTextView *tweetTextView;
@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;


@property (nonatomic) NSString *userIDStr;
@property (nonatomic, readonly) NSString *screenName;
//@property (nonatomic, readonly ) NSString *nameRetweeted;

- (void)configureView;
- (void)applyConstraints;


- (void)setScreenName:(NSString *)screenName;
//- (void)setNameRetweeted:(NSString *)nameRetweeted;

@end

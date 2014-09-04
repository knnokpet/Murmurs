//
//  MBIndividualMessageTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/02.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBAvatorImageView;
@class MBTweetTextView;
@class MBMessageView;
@interface MBIndividualMessageTableViewCell : UITableViewCell

@property (nonatomic, readonly) MBTweetTextView *tweetTextView;
@property (nonatomic, readonly) MBAvatorImageView *avatorImageView;
@property (nonatomic, readonly) MBMessageView *messageView;
@property (nonatomic, readonly) UILabel *dateLabel;

@property (nonatomic, readonly) CGFloat maxTweetTextViewWidth;
@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) CGRect tweetViewRect;
@property (nonatomic, readonly, assign) BOOL popsFromRight;
- (void)setDateString:(NSString *)dateString;
- (void)setTweetViewRect:(CGRect)tweetViewRect;
- (void)setPopsFromRight:(BOOL)popsFromRight;

@end

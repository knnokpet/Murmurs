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
#import "MBCharacterScreenNameView.h"

@protocol MBtweetViewCellLongPressDelegate;
@interface MBTweetViewCell : UITableViewCell

@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, weak) id <MBtweetViewCellLongPressDelegate> delegate;


@property (weak, nonatomic) IBOutlet MBTweetTextView *retweetView;
@property (weak, nonatomic) IBOutlet MBCharacterScreenNameView *characterScreenNameView;

@property (weak, nonatomic) IBOutlet MBTweetTextView *dateView;
@property (weak, nonatomic) IBOutlet MBTweetTextView *tweetTextView;
@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;


@property (nonatomic) NSNumber *userID;
@property (nonatomic) NSString *userIDStr;
@property (nonatomic, readonly) NSAttributedString *dateString;
@property (nonatomic, readonly) NSAttributedString *charaScreenString;

- (void)removeRetweetView;

- (void)setDateString:(NSAttributedString *)dateString;
- (void)setCharaScreenString:(NSAttributedString *)charaScreenString;

@end

@protocol MBtweetViewCellLongPressDelegate <NSObject>

- (void)didLongPressTweetViewCell:(MBTweetViewCell *)cell atPoint:(CGPoint)touchPoint;

@end

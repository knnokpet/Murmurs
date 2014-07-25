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
#import "MBFavoriteView.h"
#import "MBTimelineImageContainerView.h"

@protocol MBtweetViewCellLongPressDelegate;
@interface MBTweetViewCell : UITableViewCell

@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, weak) id <MBtweetViewCellLongPressDelegate> delegate;


@property (weak, nonatomic) IBOutlet MBTweetTextView *retweetView;
@property (weak, nonatomic) IBOutlet MBCharacterScreenNameView *characterScreenNameView;

@property (weak, nonatomic) IBOutlet MBTweetTextView *dateView;
@property (weak, nonatomic) IBOutlet MBTweetTextView *tweetTextView;
@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet MBFavoriteView *favoriteView;
@property (weak, nonatomic) IBOutlet MBTimelineImageContainerView *imageContainerView;



@property (nonatomic) NSNumber *userID;
@property (nonatomic) NSString *userIDStr;
@property (nonatomic, readonly) NSAttributedString *dateString;
@property (nonatomic, readonly) NSAttributedString *charaScreenString;
@property (nonatomic, readonly) BOOL favorited;
@property (nonatomic, readonly) BOOL geod;

- (void)removeRetweetView;
- (void)removeFavoriteView;
- (void)removeImageContainerView;

- (void)setDateString:(NSAttributedString *)dateString;
- (void)setCharaScreenString:(NSAttributedString *)charaScreenString;
- (void)setFavorited:(BOOL)favorited;
- (void)setGeod:(BOOL)geod;

@end

@protocol MBtweetViewCellLongPressDelegate <NSObject>

- (void)didLongPressTweetViewCell:(MBTweetViewCell *)cell atPoint:(CGPoint)touchPoint;

@end

//
//  MBTweetViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAvatorImageView.h"
#import "MBTimelineImageContainerView.h"

@class MBTweetTextView;
@class MBCharacterScreenNameView;
@class MBRetweetView;
@class MBFavoriteView;
@class MBPlaceWithGeoIconView;
@protocol MBtweetViewCellLongPressDelegate;
@interface MBTweetViewCell : UITableViewCell

@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, weak) id <MBtweetViewCellLongPressDelegate> delegate;


@property (weak, nonatomic) IBOutlet MBCharacterScreenNameView *characterScreenNameView;
@property (weak, nonatomic) IBOutlet MBRetweetView *retweeterView;
@property (weak, nonatomic) IBOutlet MBPlaceWithGeoIconView *placeNameView;

@property (weak, nonatomic) IBOutlet MBTweetTextView *dateView;
@property (weak, nonatomic) IBOutlet MBTweetTextView *tweetTextView;
@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet MBFavoriteView *favoriteView;
@property (weak, nonatomic) IBOutlet MBTimelineImageContainerView *imageContainerView;



@property (nonatomic) NSNumber *userID;
@property (nonatomic) NSString *userIDStr;
@property (nonatomic, readonly) NSAttributedString *dateString;
@property (nonatomic, readonly) NSAttributedString *charaScreenString;
@property (nonatomic, readonly) NSAttributedString *placeString;

- (void)addAvatorImage:(UIImage *)image;
- (CGSize)avatorImageViewSize;
- (CGFloat)avatorImageViewRadius;

- (void)removeRetweetView;
- (void)removePlaceNameView;
- (void)removeFavoriteView;
- (void)removeImageContainerView;

- (void)setDateString:(NSAttributedString *)dateString;
- (void)setCharaScreenString:(NSAttributedString *)charaScreenString;
- (void)setPlaceString:(NSAttributedString *)placeString;

@end

@protocol MBtweetViewCellLongPressDelegate <NSObject>

- (void)didLongPressTweetViewCell:(MBTweetViewCell *)cell atPoint:(CGPoint)touchPoint;

@end

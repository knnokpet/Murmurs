//
//  MBTweetViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAvatorImageView.h"

@class MBTweetTextView;
@class MBCharacterScreenNameView;
@class MBRetweetView;
@class MBFavoriteView;
@class MBPlaceWithGeoIconView;
@class MBMediaImageView;
@protocol MBtweetViewCellLongPressDelegate;
@interface MBTweetViewCell : UITableViewCell

@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, weak) id <MBtweetViewCellLongPressDelegate> delegate;


@property (nonatomic) MBCharacterScreenNameView *characterScreenNameView;
@property (nonatomic) MBTweetTextView *dateView;
@property (nonatomic) MBTweetTextView *tweetTextView;
@property (nonatomic) MBAvatorImageView *avatorImageView;
@property (nonatomic) MBFavoriteView *favoriteView;
@property (nonatomic) MBMediaImageView *mediaImageView;
@property (nonatomic) MBRetweetView *retweeterView;
@property (nonatomic) MBPlaceWithGeoIconView *placeNameView;


@property (nonatomic, readonly, assign) BOOL requireFavorite;
@property (nonatomic, readonly, assign) BOOL requirePlace;
@property (nonatomic, readonly, assign) BOOL requireRetweet;
@property (nonatomic, readonly, assign) BOOL requireMediaImage;

@property (nonatomic) NSNumber *userID;
@property (nonatomic) NSString *userIDStr;
@property (nonatomic, readonly) NSAttributedString *dateString;
@property (nonatomic, readonly) NSAttributedString *charaScreenString;
@property (nonatomic, readonly) NSAttributedString *placeString;


+ (CGFloat)heightForCellWithTweetText:(NSAttributedString *)tweetText constraintSize:(CGSize)constraintSize lineSpace:(CGFloat)lineSpace paragraphSpace:(CGFloat)paragraphSpace font:(UIFont *)font isRetweet:(BOOL)isRetweet isPlace:(BOOL)isPlace isMedia:(BOOL)isMedia;
- (void)commonLayouts;

- (void)addAvatorImage:(UIImage *)image;
- (CGSize)avatorImageViewSize;
- (CGFloat)avatorImageViewRadius;

- (void)setRequireFavorite:(BOOL)requireFavorite;
- (void)setRequirePlace:(BOOL)requirePlace;
- (void)setRequireRetweet:(BOOL)requireRetweet;
- (void)setRequireMediaImage:(BOOL)requireMediaImage;

- (void)setDateString:(NSAttributedString *)dateString;
- (void)setCharaScreenString:(NSAttributedString *)charaScreenString;
- (void)setPlaceString:(NSAttributedString *)placeString;

@end

@protocol MBtweetViewCellLongPressDelegate <NSObject>

- (void)didLongPressTweetViewCell:(MBTweetViewCell *)cell atPoint:(CGPoint)touchPoint;

@end

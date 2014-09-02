//
//  MBDetailTweetFavoRetTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/20.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailTweetFavoRetTableViewCell : UITableViewCell
@property (nonatomic, readonly) UIButton *favoriteButton;
@property (nonatomic, readonly) UIButton *retweetButton;
@property (nonatomic, readonly) UIImage *favoriteImage;
@property (nonatomic, readonly) UIImage *retweetImage;
@property (nonatomic, readonly) NSString *favoriteCountStr;
@property (nonatomic, readonly) NSString *retweetCountStr;
@property (nonatomic, readonly, assign) BOOL requireFavorite;
@property (nonatomic, readonly, assign) BOOL requireRetweet;

- (void)setFavoriteImage:(UIImage *)favoriteImage;
- (void)setRetweetImage:(UIImage *)retweetImage;
- (void)setFavoriteCountStr:(NSString *)favoriteCountStr;
- (void)setRetweetCountStr:(NSString *)retweetCountStr;
- (void)setRequireFavorite:(BOOL)requireFavorite;
- (void)setRequireRetweet:(BOOL)requireRetweet;

@end

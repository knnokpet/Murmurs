//
//  MBDetailTweetFavoriteRetweetTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/06.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailTweetFavoriteRetweetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *retweetImageView;
@property (weak, nonatomic) IBOutlet UILabel *retweetTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;
@property (weak, nonatomic) IBOutlet UILabel *favoriteTitleLabel;

@property (nonatomic, readonly, assign) BOOL isRetweeted;
@property (nonatomic, readonly, assign) BOOL isFavorited;
@property (nonatomic, readonly) NSInteger retweetCount;
@property (nonatomic, readonly) NSInteger favoriteCount;
- (void)setIsRetweeted:(BOOL)isRetweeted;
- (void)setIsFavorited:(BOOL)isFavorited;
- (void)setRetweetCount:(NSInteger)retweetCount;
- (void)setFavoriteCount:(NSInteger)favoriteCount;

@end

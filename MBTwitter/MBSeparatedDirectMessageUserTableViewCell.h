//
//  MBSeparatedDirectMessageUserTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBAvatorImageView;
@class MBCharacterScreenNameView;
@interface MBSeparatedDirectMessageUserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet MBCharacterScreenNameView *characterScreenNameView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSAttributedString *charaScreenString;
@property (nonatomic, readonly) NSString *subtitleString;
@property (nonatomic, readonly) NSString *userIDStr;

- (void)setDateString:(NSString *)dateString;
- (void)setCharaScreenString:(NSAttributedString *)charaScreenString;
- (void)setSubtitleString:(NSString *)subtitleString;
- (void)setUserIDStr:(NSString *)userIDStr;

- (void)addAvatorImage:(UIImage *)image;
- (CGSize)avatorImageViewSize;
- (CGFloat)avatorImageViewRadius;

@end

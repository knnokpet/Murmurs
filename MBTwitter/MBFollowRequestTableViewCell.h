//
//  MBFollowRequestTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBAvatorImageView;
@interface MBFollowRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *characterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (nonatomic, readonly) NSNumber *userID;
@property (nonatomic, readonly) NSString *userIDStr;
@property (nonatomic, readonly) NSString *characterName;
@property (nonatomic, readonly) NSString *screenName;
- (void)setUserID:(NSNumber *)userID;
- (void)setUserIDStr:(NSString *)userIDStr;
- (void)setCharacterName:(NSString *)characterName;
- (void)setScreenName:(NSString *)screenName;

@end

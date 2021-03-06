//
//  MBDetailTweetUserTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailTweetUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *characterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedBadgeImageView;

@property (nonatomic, readonly) NSString *screenName;
@property (nonatomic, readonly, assign) BOOL isVerified;
- (void)setScreenName:(NSString *)screenName;
- (void)setIsVerified:(BOOL)isVerified;

@end

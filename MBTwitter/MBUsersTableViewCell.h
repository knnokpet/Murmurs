//
//  MBUsersTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBUsersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *characterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

@property (nonatomic, readonly) NSString *screenName;
- (void)setScreenName:(NSString *)screenName;

@end

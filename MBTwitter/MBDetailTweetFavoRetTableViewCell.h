//
//  MBDetailTweetFavoRetTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/20.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailTweetFavoRetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;

- (void)removeFavoriteButton;
- (void)removeRetweetButton;

@end

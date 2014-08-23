//
//  MBDetailTweetActionsTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBTitleWithImageButton;
@interface MBDetailTweetActionsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MBTitleWithImageButton *replyButton;
@property (weak, nonatomic) IBOutlet MBTitleWithImageButton *retweetButton;
@property (weak, nonatomic) IBOutlet MBTitleWithImageButton *favoriteButton;


@end

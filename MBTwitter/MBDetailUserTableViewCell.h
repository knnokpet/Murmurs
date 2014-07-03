//
//  MBDetailUserTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *MessageButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (nonatomic, assign) BOOL canMessage;
@property (nonatomic, assign) BOOL canFollow;
- (void)setCanMessage:(BOOL)canMessage;
- (void)setCanFollow:(BOOL)canFollow;

@end

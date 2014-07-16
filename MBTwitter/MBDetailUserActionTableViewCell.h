//
//  MBDetailUserActionTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailUserActionTableViewCell : UITableViewCell

@property (nonatomic, readonly) UIButton *replyButton;
@property (nonatomic, readonly) UIButton *otherButton;
@property (nonatomic, readonly) UIButton *followButton;
@property (nonatomic) UIButton *messageButton;

@property (nonatomic, assign) BOOL canMessage;
@property (nonatomic, assign) BOOL canFollow;
@property (nonatomic, assign) BOOL followsMyAccount;
@property (nonatomic, assign) BOOL sentFollowRequest;
@property (nonatomic, assign) BOOL isBlocking;
- (void)setCanMessage:(BOOL)canMessage;
- (void)setCanFollow:(BOOL)canFollow;
- (void)setFollowsMyAccount:(BOOL)followsMyAccount;
- (void)setSentFollowRequest:(BOOL)sentFollowRequest;
- (void)setIsBlocking:(BOOL)isBlocking;

@end

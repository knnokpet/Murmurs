//
//  MBDetailUserActionTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailUserActionTableViewCell.h"

@implementation MBDetailUserActionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonInit];
        [self commonView];
    }
    return self;
}

- (void)commonInit
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)commonView
{
    _replyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.replyButton setTitle:NSLocalizedString(@"Reply", nil) forState:UIControlStateNormal];
    [self.contentView addSubview:self.replyButton];
    _messageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.messageButton setTitle:NSLocalizedString(@"Message", nil) forState:UIControlStateNormal];
    _otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.otherButton setTitle:NSLocalizedString(@"Other", nil) forState:UIControlStateNormal];
    [self.contentView addSubview:self.otherButton];
    _followButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.followButton setTitle:NSLocalizedString(@"Follow!", nil) forState:UIControlStateNormal];
    [self.contentView addSubview:self.followButton];
    
    [self.replyButton sizeToFit];
    [self.messageButton sizeToFit];
    [self.otherButton sizeToFit];
    [self.followButton sizeToFit];
}

- (void)awakeFromNib
{
    // Initialization code
}

#pragma mark -
#pragma mark Setter Getter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCanMessage:(BOOL)canMessage
{
    _canMessage = canMessage;
    self.messageButton.enabled = canMessage;
    if (canMessage) {
        [self.contentView addSubview:self.messageButton];
    } else {
        if (self.messageButton.superview) {
            [self.messageButton removeFromSuperview];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setCanFollow:(BOOL)canFollow
{
    _canFollow = canFollow;
    if (canFollow) {
        self.followButton.enabled = YES;
        [self.followButton setTitle:NSLocalizedString(@"Follow", nil) forState:UIControlStateNormal];
        self.followButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [self.followButton sizeToFit];
        
    } else {
        self.followButton.enabled = NO;
        [self.followButton setTitle:NSLocalizedString(@"Now Following!", nil) forState:UIControlStateNormal];
        self.followButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.followButton sizeToFit];
    }
    [self setNeedsLayout];
}

- (void)setFollowsMyAccount:(BOOL)followsMyAccount
{
    _followsMyAccount = followsMyAccount;
    if (followsMyAccount) {
        if (self.canFollow) {
            [self.followButton setTitle:NSLocalizedString(@"Follow Back!", nil) forState:UIControlStateNormal];
        }
    } else {
    }
    self.followButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.followButton sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setSentFollowRequest:(BOOL)sentFollowRequest
{
    _sentFollowRequest = sentFollowRequest;
    if (sentFollowRequest) {
        [self.followButton setTitle:NSLocalizedString(@"Sent Request", nil) forState:UIControlStateNormal];
        self.followButton.enabled = NO;
    } else {
        
    }
    
    self.followButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.followButton sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setIsBlocking:(BOOL)isBlocking
{
    _isBlocking = isBlocking;
    if (isBlocking) {
        [self.followButton setTitle:NSLocalizedString(@"Blocking", nil) forState:UIControlStateNormal];
        self.followButton.enabled = NO;
    }
    
    self.followButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.followButton sizeToFit];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat centerOriginY = self.contentView.bounds.size.height / 2;
    CGFloat edgheMargin = 20.0f;
    CGFloat buttonMargin = 8.0f;
    
    CGRect replyRect = self.replyButton.frame;
    replyRect.origin = CGPointMake(edgheMargin, centerOriginY - replyRect.size.height / 2);
    self.replyButton.frame = replyRect;
    
    CGRect messageRect = self.messageButton.frame;
    messageRect.origin = CGPointMake(self.replyButton.frame.origin.x + self.replyButton.frame.size.width + buttonMargin, centerOriginY - messageRect.size.height / 2);
    self.messageButton.frame = messageRect;
    
    CGRect otherRect = self.otherButton.frame;
    if (self.messageButton.superview) {
        otherRect.origin = CGPointMake(self.messageButton.frame.origin.x + self.messageButton.frame.size.width + buttonMargin, centerOriginY - messageRect.size.height / 2);
    } else {
        otherRect.origin = CGPointMake(self.replyButton.frame.origin.x + self.replyButton.frame.size.width + buttonMargin, centerOriginY - messageRect.size.height / 2);
    }
    self.otherButton.frame = otherRect;
    
    CGRect followRect = self.followButton.frame;
    followRect.origin = CGPointMake(self.bounds.size.width - (followRect.size.width + edgheMargin), centerOriginY - followRect.size.height / 2);
    self.followButton.frame = followRect;
}

@end

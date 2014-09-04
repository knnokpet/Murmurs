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
    self.isMyAccount = NO;
}

- (void)commonView
{
    _tweetButton = [[MBTitleWithImageButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48) title:NSLocalizedString(@"Tweet", nil) image:[UIImage imageNamed:@"Pen-ActionCell"]];
    [self.tweetButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self.contentView addSubview:self.tweetButton];
    
    _messageButton = [[MBTitleWithImageButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48) title:NSLocalizedString(@"Message", nil) image:[UIImage imageNamed:@"Message-ActionCell"]];
    [self.messageButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    
    
    _otherButton = [[MBTitleWithImageButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48) title:NSLocalizedString(@"More", nil) image:[UIImage imageNamed:@"More-ActionCell"]];
    [self.otherButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self.contentView addSubview:self.otherButton];
    
    _followButton = [[MBTitleWithImageButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48) title:NSLocalizedString(@"Follow!", nil) image:[UIImage imageNamed:@"man-Plus-ActionCell"]];
    [self.followButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self.contentView addSubview:self.followButton];
    
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
        [self.followButton setTitle:NSLocalizedString(@"Follow!", nil) forState:UIControlStateNormal];
        [self.followButton setButtonTitle:NSLocalizedString(@"Follow!", nil)];
        [self.followButton setButtonImage:[UIImage imageNamed:@"man-Plus-ActionCell"]];
        [self.followButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        
    } else {
        self.followButton.enabled = NO;
        [self.followButton setTitle:NSLocalizedString(@"Following!", nil) forState:UIControlStateNormal];
        [self.followButton setButtonTitle:NSLocalizedString(@"Following!", nil)];
        [self.followButton setButtonImage:[UIImage imageNamed:@"man-Check-Disenabled"]];
        [self.followButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
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
    [self.followButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    
    [self setNeedsLayout];
}

- (void)setSentFollowRequest:(BOOL)sentFollowRequest
{
    _sentFollowRequest = sentFollowRequest;
    if (sentFollowRequest) {
        [self.followButton setTitle:NSLocalizedString(@"Sent Request", nil) forState:UIControlStateNormal];
        [self.followButton setButtonImage:[UIImage imageNamed:@"man-Check-Disenabled"]];
        self.followButton.enabled = NO;
    } else {
        
    }
    
    [self.followButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    
    [self setNeedsLayout];
}

- (void)setIsBlocking:(BOOL)isBlocking
{
    _isBlocking = isBlocking;
    if (isBlocking) {
        [self.followButton setTitle:NSLocalizedString(@"Blocking", nil) forState:UIControlStateNormal];
        self.followButton.enabled = NO;
    }
    
    [self.followButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self.followButton sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setIsMyAccount:(BOOL)isMyAccount
{
    _isMyAccount = isMyAccount;
    
    if (isMyAccount == YES) {
        [self.messageButton removeFromSuperview];
        [self.otherButton removeFromSuperview];
        [self.followButton removeFromSuperview];
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentBounds = self.contentView.bounds;
    CGFloat centerOriginY = self.contentView.bounds.size.height / 2;
    CGFloat buttonMargin = 0.0f;
    [self.tweetButton sizeToFit];
    [self.messageButton sizeToFit];
    [self.otherButton sizeToFit];
    [self.followButton sizeToFit];
    
    CGRect tweetRect = self.tweetButton.frame;
    tweetRect.origin = CGPointMake(contentBounds.origin.x, centerOriginY - tweetRect.size.height / 2);
    self.tweetButton.frame = tweetRect;
    
    CGRect messageRect = self.messageButton.frame;
    messageRect.origin = CGPointMake(self.tweetButton.frame.origin.x + self.tweetButton.frame.size.width + buttonMargin, centerOriginY - messageRect.size.height / 2);
    self.messageButton.frame = messageRect;
    
    CGRect otherRect = self.otherButton.frame;
    if (self.messageButton.superview) {
        otherRect.origin = CGPointMake(self.messageButton.frame.origin.x + self.messageButton.frame.size.width + buttonMargin, centerOriginY - messageRect.size.height / 2);
    } else {
        otherRect.origin = CGPointMake(self.tweetButton.frame.origin.x + self.tweetButton.frame.size.width + buttonMargin, centerOriginY - messageRect.size.height / 2);
    }
    self.otherButton.frame = otherRect;
    
    CGRect followRect = self.followButton.frame;
    followRect.origin = CGPointMake(contentBounds.size.width - followRect.size.width , centerOriginY - followRect.size.height / 2);
    self.followButton.frame = followRect;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hittedView = [super hitTest:point withEvent:event];
    if (hittedView == self) {
        return nil;
    } else if (hittedView == self.contentView) {
        return nil;
    }
    
    return hittedView;
}

@end

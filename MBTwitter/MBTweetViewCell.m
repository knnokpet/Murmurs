//
//  MBTweetViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetViewCell.h"

#import "MBTweetTextView.h"
#import "MBTextLayout.h"
#import "MBLinkText.h"

@implementation MBTweetViewCell
#pragma mark -
#pragma mark Initialize
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self common];
    [self configureView];
}

- (void)common
{
    //self.avatorImageView.backgroundColor = [UIColor clearColor];
    self.avatorImageView.layer.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0].CGColor;
    self.avatorImageView.layer.cornerRadius = 4.0f;
    self.avatorImageView.layer.masksToBounds = NO;
    self.avatorImageView.layer.shouldRasterize = YES;
    
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress)];
    [self addGestureRecognizer:self.longPressRecognizer];
}

- (void)configureView
{
    
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    if (0 < screenName.length) {
        NSString *nameWithAtMark = [NSString stringWithFormat:@"@%@", screenName];
        self.screenNameLabel.text = nameWithAtMark;
    }
}
/*
- (void)setNameRetweeted:(NSString *)nameRetweeted
{
    _nameRetweeted = nameRetweeted;
    
    self.retweetLabel.text = nameRetweeted;
    if (0 < [nameRetweeted length]) {
        NSString *retweetStr = NSLocalizedString(@"Retweeted by ", nil);
        self.retweetLabel.text = [NSString stringWithFormat:@"%@%@", retweetStr, nameRetweeted];
    }
}*/

- (void)setUserIDStr:(NSString *)userIDStr
{
    _userIDStr = userIDStr;
    [self.avatorImageView setUserIDStr:userIDStr];
}

#pragma mark -

- (void)applyConstraints
{
    if (0 == [self.retweetView.attributedString length]) {
        [self removeRetweetLabelConstraints];
        [self.retweetView setHidden:YES];
    } else {
        [self addRetweetLabelConstraints];
        [self.retweetView setHidden:NO];
    }
}
- (void)addRetweetLabelConstraints
{
    self.topConstraint.constant = 4.0f;
    self.bottomSpace.constant = 12.0f;
    self.heightConstraint.constant = 18.0f;
}

- (void)removeRetweetLabelConstraints
{
    self.topConstraint.constant = 0.f;
    //self.bottomSpace.constant = 0.f;
    self.heightConstraint.constant = 0.0f;
}

- (void)didLongPress
{
    CGPoint touchedPoint = [self.longPressRecognizer locationInView:self];
    
    if (UIGestureRecognizerStateBegan == self.longPressRecognizer.state) {
        if ([_delegate respondsToSelector:@selector(didLongPressTweetViewCell:atPoint:)]) {
            [_delegate didLongPressTweetViewCell:self atPoint:touchedPoint];
        }
    }
    
}

#pragma mark -
#pragma mark View
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *touchedView = [super hitTest:point withEvent:event];
    self.longPressRecognizer.enabled = YES;
    
    if ([touchedView isKindOfClass:[MBTweetTextView class]]) {
        MBTweetTextView *tweetTextView = (MBTweetTextView *)touchedView;
        MBLinkText *linkText = [tweetTextView linkAtPoint:[tweetTextView convertPoint:point fromView:self]];
        if (linkText) {
            self.longPressRecognizer.enabled = NO;
        }
        
        return touchedView;
    } else if ([touchedView isKindOfClass:[MBAvatorImageView class]]) {
        self.longPressRecognizer.enabled = NO;
        return touchedView;
    }
    
    return touchedView;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.chacacterNameLabel sizeToFit];
    [self.screenNameLabel sizeToFit];
    [self.dateView sizeToFit];
    
    CGFloat namesSpace = (self.dateView.frame.origin.x - self.chacacterNameLabel.frame.origin.x);
    if (namesSpace < self.chacacterNameLabel.frame.size.width + self.screenNameLabel.frame.size.width) {
        CGRect screenFrame = self.screenNameLabel.frame;
        CGFloat screenWidth = namesSpace - self.chacacterNameLabel.frame.size.width;
        if (screenWidth < 0) {
            screenWidth = 0.0f;
        }
        screenFrame.size.width = screenWidth;
        self.screenNameLabel.frame = screenFrame;
    }
    CGRect screenFrame = self.screenNameLabel.frame;
    screenFrame.origin.x = self.chacacterNameLabel.frame.origin.x + self.chacacterNameLabel.frame.size.width + 8;
    self.screenNameLabel.frame = screenFrame;
    
    if ( namesSpace < self.chacacterNameLabel.frame.size.width) {
        CGRect characterFrame = self.chacacterNameLabel.frame;
        characterFrame.size.width = (self.dateView.frame.origin.x - self.chacacterNameLabel.frame.origin.x - 8);
        self.chacacterNameLabel.frame = characterFrame;
        
        CGRect screenFrame = self.screenNameLabel.frame;
        screenFrame.size.width = 0.f;
        self.screenNameLabel.frame = screenFrame;
    }
}

@end

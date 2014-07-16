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
    
    self.dateView.alignment = NSTextAlignmentRight;
}

- (void)common
{
    self.avatorImageView.backgroundColor = [UIColor clearColor];
    //self.avatorImageView.layer.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0].CGColor;
    self.avatorImageView.layer.cornerRadius = 4.0f;
    self.avatorImageView.layer.masksToBounds = NO;
    self.avatorImageView.layer.shouldRasterize = YES;
    
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress)];
    [self addGestureRecognizer:self.longPressRecognizer];
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateString:(NSAttributedString *)dateString
{
    _dateString = dateString;
    self.dateView.attributedString = dateString;
}

- (void)setCharaScreenString:(NSAttributedString *)charaScreenString
{
    _charaScreenString = charaScreenString;
    self.characterScreenNameView.characterScreenString = charaScreenString;
}

- (void)setUserIDStr:(NSString *)userIDStr
{
    _userIDStr = userIDStr;
    [self.avatorImageView setUserIDStr:userIDStr];
}

- (void)setUserID:(NSNumber *)userID
{
    _userID = userID;
    [self.avatorImageView setUserID:userID];
}

#pragma mark -

- (void)removeRetweetView
{
    if (self.retweetView.superview) {
        [self.retweetView removeFromSuperview];
        self.retweetView = nil;
    }
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

@end

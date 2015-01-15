//
//  MBTweetViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetViewCell.h"

#import "MBCharacterScreenNameView.h"
#import "MBTweetTextView.h"
#import "MBRetweetView.h"
#import "MBFavoriteView.h"
#import "MBPlaceWithGeoIconView.h"

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
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        self.preservesSuperviewLayoutMargins = NO;
    }
}

- (void)common
{
    self.avatorImageView.backgroundColor = [UIColor clearColor];
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

- (void)setUserIDStr:(NSString *)userIDStr
{
    _userIDStr = userIDStr;
}

- (void)setUserID:(NSNumber *)userID
{
    _userID = userID;
    [self.avatorImageView setUserID:userID];
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

- (void)setPlaceString:(NSAttributedString *)placeString
{
    _placeString = placeString;
    self.placeNameView.placeString = placeString;
}

#pragma mark -
- (void)addAvatorImage:(UIImage *)image
{
    if (!image) {
        return;
    }
    
    self.avatorImageView.alpha = 0;
    self.avatorImageView.avatorImage = image;
    [UIView animateWithDuration:0.3f animations:^{
        self.avatorImageView.alpha = 1.0f;
    }];
}

- (CGSize)avatorImageViewSize
{
    CGSize avatorImageSize = CGSizeMake(self.avatorImageView.bounds.size.width, self.avatorImageView.bounds.size.height);
    return avatorImageSize;
}

- (CGFloat)avatorImageViewRadius
{
    CGFloat radius = self.avatorImageView.layer.cornerRadius;
    return radius;
}

- (void)removeRetweetView
{
    if (self.retweeterView.superview) {
        [self.retweeterView removeFromSuperview];
        self.retweeterView = nil;
    }
}

- (void)removePlaceNameView
{
    if (self.placeNameView.superview) {
        [self.placeNameView removeFromSuperview];
        self.placeNameView = nil;
    }
}

- (void)removeFavoriteView
{
    if (self.favoriteView.superview) {
        [self.favoriteView removeFromSuperview];
        self.favoriteView = nil;
    }
}

- (void)removeImageContainerView
{
    if (self.imageContainerView.superview) {
        [self.imageContainerView removeFromSuperview];
        self.imageContainerView = nil;
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
    } else if ([touchedView isKindOfClass:[MBMediaImageView class]]) {
        return touchedView;
    }
    
    return touchedView;
    
}

@end

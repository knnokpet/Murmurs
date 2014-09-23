//
//  MBDetailTweetFavoRetTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/20.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetFavoRetTableViewCell.h"

@implementation MBDetailTweetFavoRetTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
        UIColor  *titleColor = [UIColor blackColor];
        UIFont *titleFont = [UIFont systemFontOfSize:15.0f];
        
        _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.favoriteButton setTitleColor:titleColor forState:UIControlStateNormal];
        [self.favoriteButton.titleLabel setFont:titleFont];
        
        
        _retweetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.retweetButton setTitleColor:titleColor forState:UIControlStateNormal];
        [self.retweetButton.titleLabel setFont:titleFont];
        
        
        
        [self.contentView addSubview:self.favoriteButton];
        [self.contentView addSubview:self.retweetButton];
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self commonInit];
}

- (void)commonInit
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Accessor
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFavoriteImage:(UIImage *)favoriteImage
{
    _favoriteImage = favoriteImage;
    [self.favoriteButton setImage:favoriteImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setRetweetImage:(UIImage *)retweetImage
{
    _retweetImage = retweetImage;
    [self.retweetButton setImage:retweetImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setFavoriteCountStr:(NSString *)favoriteCountStr
{
    _favoriteCountStr = favoriteCountStr;
    [self.favoriteButton setTitle:favoriteCountStr forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setRetweetCountStr:(NSString *)retweetCountStr
{
    _retweetCountStr = retweetCountStr;
    [self.retweetButton setTitle:retweetCountStr forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setRequireFavorite:(BOOL)requireFavorite
{
    _requireFavorite = requireFavorite;
    [self updateFavoriteButton];
    [self setNeedsLayout];
}

- (void)setRequireRetweet:(BOOL)requireRetweet
{
    _requireRetweet = requireRetweet;
    
    [self updateRetweetButton];
    
    [self setNeedsLayout];
}

#pragma mark - Instance Methods
- (void)updateFavoriteButton
{
    if (self.requireFavorite) {
        [self addFavoriteButton];
    } else {
        [self removeFavoriteButton];
    }
}

- (void)updateRetweetButton
{
    if (self.requireRetweet) {
        [self addRetweetButton];
    } else {
        [self removeRetweetButton];
    }
}

- (void)addFavoriteButton
{
    if (!self.favoriteButton.superview) {
        [self.contentView addSubview:self.favoriteButton];
    }
}

- (void)addRetweetButton
{
    if (!self.retweetButton.superview) {
        [self.contentView addSubview:self.retweetButton];
    }
}

- (void)removeFavoriteButton
{
    if (self.favoriteButton.superview) {
        [self.favoriteButton removeFromSuperview];
    }
}

- (void)removeRetweetButton
{
    if (self.retweetButton.superview) {
        [self.retweetButton removeFromSuperview];
    }
}

#pragma mark - View
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.favoriteButton sizeToFit];
    [self.retweetButton sizeToFit];
    
    CGRect contentBounds = self.contentView.bounds;
    CGFloat sideEdge = 12.0f;
    CGFloat buttonBetweetMargin = 8.0f;
    CGFloat titleLeftEdgeMargin = 8.0f;
    
    CGRect retRect = self.retweetButton.frame;
    UIEdgeInsets retTitleInsets = self.retweetButton.titleEdgeInsets;
    retTitleInsets.left = titleLeftEdgeMargin;
    [self.retweetButton setTitleEdgeInsets:retTitleInsets];
    retRect.size.width += titleLeftEdgeMargin;
    retRect.origin = CGPointMake(contentBounds.origin.x + sideEdge, (contentBounds.size.height - retRect.size.height) / 2);
    self.retweetButton.frame = retRect;
    
    
    CGRect favoRect = self.favoriteButton.frame;
    UIEdgeInsets favoTitleInsets = self.favoriteButton.titleEdgeInsets;
    favoTitleInsets.left = titleLeftEdgeMargin;
    [self.favoriteButton setTitleEdgeInsets:favoTitleInsets];
    favoRect.size.width += titleLeftEdgeMargin;
    favoRect.origin = CGPointMake(retRect.origin.x + retRect.size.width + buttonBetweetMargin, (contentBounds.size.height - favoRect.size.height) / 2);
    if (!self.requireRetweet) {
        favoRect.origin = CGPointMake(contentBounds.origin.x + sideEdge, (contentBounds.size.height - favoRect.size.height) / 2);
    }
    self.favoriteButton.frame = favoRect;
    
}

@end

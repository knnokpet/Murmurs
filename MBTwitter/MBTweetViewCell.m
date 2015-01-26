//
//  MBTweetViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetViewCell.h"
#import <QuartzCore/QuartzCore.h>

#import "MBCharacterScreenNameView.h"
#import "MBTweetTextView.h"
#import "MBRetweetView.h"
#import "MBFavoriteView.h"
#import "MBPlaceWithGeoIconView.h"

#import "MBMediaImageView.h"

const CGFloat avatorImageViewWidthHeight = 48;
const CGFloat attachedViewHeight = 18;

const CGFloat mediaImageHeight = 128;
const CGFloat dateViewWidth = 40;
const CGFloat favoriteViewWidthHeight = 20;

struct Layouts {
    NSInteger top;
    NSInteger left;
    NSInteger right;
    NSInteger bottom;
};

@interface MBTweetViewCell()
{
    struct Layouts avatorImageViewLayouts;
    struct Layouts characterScreenNameViewLayouts;
    struct Layouts dateViewLayouts;
    struct Layouts tweetTextViewLayouts;
    struct Layouts favoriteViewLayouts;
    struct Layouts mediaImageContainerViewLayouts;
    struct Layouts retweetViewLayouts;
    struct Layouts placeNameViewLayouts;
}

@end

@implementation MBTweetViewCell
#pragma mark -
#pragma mark Class Method
+ (CGFloat)heightForCellWithTweetText:(NSAttributedString *)tweetText constraintSize:(CGSize)constraintSize lineSpace:(CGFloat)lineSpace paragraphSpace:(CGFloat)paragraphSpace font:(UIFont *)font isRetweet:(BOOL)isRetweet isPlace:(BOOL)isPlace isMedia:(BOOL)isMedia
{
    MBTweetViewCell *cell = [[MBTweetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell commonLayouts];
    
    return [cell heightForCellWithTweetText:tweetText constraintSize:constraintSize lineSpace:lineSpace paragraphSpace:paragraphSpace font:font isRetweet:isRetweet isPlace:isPlace isMedia:isMedia];
}

- (CGFloat)heightForCellWithTweetText:(NSAttributedString *)tweetText constraintSize:(CGSize)constraintSize lineSpace:(CGFloat)lineSpace paragraphSpace:(CGFloat)paragraphSpace font:(UIFont *)font isRetweet:(BOOL)isRetweet isPlace:(BOOL)isPlace isMedia:(BOOL)isMedia
{
    CGFloat minimumHeight = avatorImageViewWidthHeight + avatorImageViewLayouts.top * 2;
    
    CGFloat tweetViewMargin = characterScreenNameViewLayouts.top + attachedViewHeight + characterScreenNameViewLayouts.bottom;
    
    NSInteger tweetTextWidth = [self tweetTextWidthConstraintWidth:constraintSize.width];
    CGRect textRect = [MBTweetTextView frameRectWithAttributedString:tweetText constraintSize:CGSizeMake(tweetTextWidth, CGFLOAT_MAX) lineSpace:lineSpace paragraghSpace:paragraphSpace font:font];
    
    CGFloat bottomHeight = tweetTextViewLayouts.bottom;
    if (isRetweet && isPlace && isMedia) {
        bottomHeight = (mediaImageContainerViewLayouts.top + mediaImageHeight) + (placeNameViewLayouts.top + attachedViewHeight + placeNameViewLayouts.bottom) + (attachedViewHeight + retweetViewLayouts.bottom);
        
    } else if (isRetweet && isPlace) {
        bottomHeight = (placeNameViewLayouts.top + attachedViewHeight + placeNameViewLayouts.bottom) + (attachedViewHeight + retweetViewLayouts.bottom);
        
    } else if (isRetweet && isMedia) {
        bottomHeight = (mediaImageContainerViewLayouts.top + mediaImageHeight + mediaImageContainerViewLayouts.bottom) + (attachedViewHeight + retweetViewLayouts.bottom);
        
    } else if (isPlace && isMedia) {
        bottomHeight = (mediaImageContainerViewLayouts.top + mediaImageHeight) + (placeNameViewLayouts.top + attachedViewHeight + placeNameViewLayouts.bottom);
        
    } else if (isRetweet) {
        bottomHeight = (retweetViewLayouts.top + attachedViewHeight + retweetViewLayouts.bottom);
        minimumHeight = (avatorImageViewWidthHeight + avatorImageViewLayouts.top) + bottomHeight;
        
    } else if (isPlace) {
        bottomHeight = (placeNameViewLayouts.top + attachedViewHeight + placeNameViewLayouts.bottom);
        minimumHeight = (avatorImageViewWidthHeight + avatorImageViewLayouts.top) + bottomHeight;
        
    } else if (isMedia) {
        bottomHeight = (mediaImageContainerViewLayouts.top + mediaImageHeight + mediaImageContainerViewLayouts.bottom);
    }
    
    CGFloat customCellHeight = textRect.size.height + tweetViewMargin + bottomHeight;
    
    return  MAX(minimumHeight, customCellHeight);
}

- (CGFloat)tweetTextWidthConstraintWidth:(CGFloat)constraintWidth
{
    return constraintWidth - (tweetTextViewLayouts.left + tweetTextViewLayouts.right);
}

#pragma mark -
#pragma mark Initialize
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonLayouts];
        [self configureViews];
        [self common];
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
    self.avatorImageView.layer.cornerRadius = 4.0f;
    self.avatorImageView.layer.masksToBounds = NO;
    self.avatorImageView.layer.shouldRasterize = YES;
    self.avatorImageView.userInteractionEnabled = YES;
    
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress)];
    [self addGestureRecognizer:self.longPressRecognizer];
}

- (void)commonLayouts
{
    avatorImageViewLayouts.left = 8;
    avatorImageViewLayouts.top = 12;
    avatorImageViewLayouts.right = characterScreenNameViewLayouts.left = 8;
    characterScreenNameViewLayouts.top = 10;
    characterScreenNameViewLayouts.right = dateViewLayouts.left = 10;
    characterScreenNameViewLayouts.bottom = tweetTextViewLayouts.top = 2;
    dateViewLayouts.top = 12;
    dateViewLayouts.right = 8;
    favoriteViewLayouts.left = 4;
    favoriteViewLayouts.top = 10;
    favoriteViewLayouts.right = 4;
    tweetTextViewLayouts.left = 64;
    tweetTextViewLayouts.right = 8;
    tweetTextViewLayouts.bottom = 10;
    mediaImageContainerViewLayouts.left = 64;
    mediaImageContainerViewLayouts.right = 8;
    mediaImageContainerViewLayouts.top = 8;
    mediaImageContainerViewLayouts.bottom = 10;
    placeNameViewLayouts.left = 32;
    placeNameViewLayouts.right = 8;
    placeNameViewLayouts.top = 4;
    placeNameViewLayouts.bottom = 10;
    retweetViewLayouts.left = 32;
    retweetViewLayouts.right = 8;
    retweetViewLayouts.top = 4;
    retweetViewLayouts.bottom = 4;
}

- (void)configureViews
{
    CGSize avatorImageViewSize = CGSizeMake(avatorImageViewWidthHeight, avatorImageViewWidthHeight);
    self.avatorImageView = [[MBAvatorImageView alloc] initWithFrame:CGRectMake(avatorImageViewLayouts.left, avatorImageViewLayouts.top, avatorImageViewSize.width, avatorImageViewSize.height)];
    [self addSubview:self.avatorImageView];
    
    self.characterScreenNameView = [[MBCharacterScreenNameView alloc] initWithFrame:CGRectMake(avatorImageViewLayouts.left + avatorImageViewSize.width + characterScreenNameViewLayouts.left, characterScreenNameViewLayouts.top, 0, attachedViewHeight)];
    self.characterScreenNameView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.characterScreenNameView];
    self.tweetTextView = [[MBTweetTextView alloc] initWithFrame:CGRectMake(tweetTextViewLayouts.left, self.characterScreenNameView.frame.origin.y + self.characterScreenNameView.bounds.size.height + tweetTextViewLayouts.top, 0, 0)];
    self.tweetTextView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tweetTextView];
    self.dateView = [[MBTweetTextView alloc] initWithFrame:CGRectMake(0, dateViewLayouts.top, dateViewWidth, attachedViewHeight)];
    self.dateView.backgroundColor = [UIColor whiteColor];
    self.dateView.alignment = NSTextAlignmentRight;
    [self addSubview:self.dateView];
    
    self.favoriteView = [[MBFavoriteView alloc] initWithFrame:CGRectMake(0, favoriteViewLayouts.top, favoriteViewWidthHeight, favoriteViewWidthHeight)];
    self.mediaImageView = [[MBMediaImageView alloc] initWithFrame:CGRectMake(mediaImageContainerViewLayouts.left, 0, 0, mediaImageHeight)];
    self.placeNameView = [[MBPlaceWithGeoIconView alloc] initWithFrame:CGRectMake(placeNameViewLayouts.left, 0, 0, attachedViewHeight)];
    self.placeNameView.backgroundColor = [UIColor whiteColor];
    self.retweeterView = [[MBRetweetView alloc] initWithFrame:CGRectMake(retweetViewLayouts.left, 0, 0, attachedViewHeight)];
    self.retweeterView.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRequireFavorite:(BOOL)requireFavorite
{
    _requireFavorite = requireFavorite;
    if (requireFavorite && !self.favoriteView.superview) {
        [self addSubview:self.favoriteView];
    } else if (!requireFavorite && self.favoriteView.superview) {
        [self.favoriteView removeFromSuperview];
    }
    [self setNeedsLayout];
}

- (void)setRequirePlace:(BOOL)requirePlace
{
    _requirePlace = requirePlace;
    if (requirePlace && !self.placeNameView.superview) {
        [self addSubview:self.placeNameView];
    } else if (!requirePlace && self.placeNameView.superview) {
        [self.placeNameView removeFromSuperview];
    }
    [self setNeedsLayout];
}

- (void)setRequireRetweet:(BOOL)requireRetweet
{
    _requireRetweet = requireRetweet;
    if (requireRetweet && !self.retweeterView.superview) {
        [self addSubview:self.retweeterView];
    } else if (!requireRetweet && self.retweeterView.superview) {
        [self.retweeterView removeFromSuperview];
    }
    [self setNeedsLayout];
}

- (void)setRequireMediaImage:(BOOL)requireMediaImage
{
    _requireMediaImage = requireMediaImage;
    if (requireMediaImage && !self.mediaImageView.superview) {
        [self addSubview:self.mediaImageView];
    } else if (!requireMediaImage && self.mediaImageView.superview) {
        [self.mediaImageView removeFromSuperview];
    }
    [self setNeedsLayout];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect dateViewFrame = self.dateView.frame;
    dateViewFrame.origin.x = bounds.size.width - (dateViewFrame.size.width + dateViewLayouts.right);
    self.dateView.frame = dateViewFrame;
    
    CGRect characterScreenFrame = self.characterScreenNameView.frame;
    characterScreenFrame.size.width = dateViewFrame.origin.x - (self.avatorImageView.frame.origin.x + self.avatorImageView.bounds.size.width + characterScreenNameViewLayouts.left);
    self.characterScreenNameView.frame = characterScreenFrame;
    
    if (self.requireFavorite) {
        CGRect favoriteFrame = self.favoriteView.frame;
        favoriteFrame.origin.x = dateViewFrame.origin.x - (favoriteFrame.size.width + favoriteViewLayouts.right);
        self.favoriteView.frame = favoriteFrame;
        
        CGRect characterNameFrame = self.characterScreenNameView.frame;
        characterNameFrame.size.width = favoriteFrame.origin.x - (characterNameFrame.origin.x + favoriteViewLayouts.left);
        self.characterScreenNameView.frame = characterNameFrame;
    }
    
    NSInteger bottom = tweetTextViewLayouts.bottom;
    if (self.requirePlace && self.requireRetweet && self.requireMediaImage) {
        CGRect retweetFrame = self.retweeterView.frame;
        retweetFrame.size.width = bounds.size.width - (retweetViewLayouts.right + retweetViewLayouts.left);
        retweetFrame.origin.y = bounds.size.height - (attachedViewHeight + retweetViewLayouts.bottom);
        self.retweeterView.frame = retweetFrame;
        
        CGRect placeFrame = self.placeNameView.frame;
        placeFrame.size.width = bounds.size.width - (placeNameViewLayouts.right + placeNameViewLayouts.left);
        placeFrame.origin.y = retweetFrame.origin.y - (attachedViewHeight + placeNameViewLayouts.bottom);
        self.placeNameView.frame = placeFrame;
        
        CGRect containerFrame = self.mediaImageView.frame;
        containerFrame.size.width = bounds.size.width - (mediaImageContainerViewLayouts.left + mediaImageContainerViewLayouts.right);
        containerFrame.origin.y = placeFrame.origin.y - (mediaImageHeight + 4);
        self.mediaImageView.frame = containerFrame;
        
        bottom = bounds.size.height - (self.mediaImageView.frame.origin.y + mediaImageContainerViewLayouts.top);
        
    } else if (self.requirePlace && self.requireRetweet) {
        CGRect retweetFrame = self.retweeterView.frame;
        retweetFrame.size.width = bounds.size.width - (retweetViewLayouts.right + retweetViewLayouts.left);
        retweetFrame.origin.y = bounds.size.height - (attachedViewHeight + retweetViewLayouts.bottom);
        self.retweeterView.frame = retweetFrame;
        
        CGRect placeFrame = self.placeNameView.frame;
        placeFrame.size.width = bounds.size.width - (placeNameViewLayouts.right + placeNameViewLayouts.left);
        placeFrame.origin.y = retweetFrame.origin.y - (attachedViewHeight + placeNameViewLayouts.bottom);
        self.placeNameView.frame = placeFrame;
        
        bottom = bounds.size.height - (placeFrame.origin.y + placeNameViewLayouts.top);
        
    } else if (self.requireRetweet && self.requireMediaImage) {
        CGRect retweetFrame = self.retweeterView.frame;
        retweetFrame.size.width = bounds.size.width - (retweetViewLayouts.right + retweetViewLayouts.left);
        retweetFrame.origin.y = bounds.size.height - (attachedViewHeight + retweetViewLayouts.bottom);
        self.retweeterView.frame = retweetFrame;
        
        CGRect containerFrame = self.mediaImageView.frame;
        containerFrame.size.width = bounds.size.width - (mediaImageContainerViewLayouts.left + mediaImageContainerViewLayouts.right);
        containerFrame.origin.y = retweetFrame.origin.y - (mediaImageHeight + mediaImageContainerViewLayouts.bottom);
        self.mediaImageView.frame = containerFrame;
        
        bottom = bounds.size.height - (self.mediaImageView.frame.origin.y + mediaImageContainerViewLayouts.top);
        
    } else if (self.requirePlace && self.requireMediaImage) {
        
        CGRect placeFrame = self.placeNameView.frame;
        placeFrame.size.width = bounds.size.width - (placeNameViewLayouts.right + placeNameViewLayouts.left);
        placeFrame.origin.y = bounds.size.height - (attachedViewHeight + placeNameViewLayouts.bottom);
        self.placeNameView.frame = placeFrame;
        
        CGRect containerFrame = self.mediaImageView.frame;
        containerFrame.size.width = bounds.size.width - (mediaImageContainerViewLayouts.left + mediaImageContainerViewLayouts.right);
        containerFrame.origin.y = placeFrame.origin.y - (mediaImageHeight + 4);
        self.mediaImageView.frame = containerFrame;
        
        bottom = bounds.size.height - (self.mediaImageView.frame.origin.y + mediaImageContainerViewLayouts.top);
        
    } else if (self.requirePlace) {
        CGRect placeFrame = self.placeNameView.frame;
        placeFrame.size.width = bounds.size.width - (placeNameViewLayouts.right + placeNameViewLayouts.left);
        placeFrame.origin.y = bounds.size.height - (attachedViewHeight + placeNameViewLayouts.bottom);
        self.placeNameView.frame = placeFrame;
        
        bottom = bounds.size.height - (self.placeNameView.frame.origin.y + placeNameViewLayouts.top);
        
    } else if (self.requireRetweet) {
        CGRect retweetFrame = self.retweeterView.frame;
        retweetFrame.size.width = bounds.size.width - (retweetViewLayouts.right + retweetViewLayouts.left);
        retweetFrame.origin.y = bounds.size.height - (attachedViewHeight + retweetViewLayouts.bottom);
        self.retweeterView.frame = retweetFrame;
        
        bottom = bounds.size.height - (self.retweeterView.frame.origin.y + retweetViewLayouts.top);
    } else if (self.requireMediaImage) {
        CGRect containerFrame = self.mediaImageView.frame;
        containerFrame.size.width = bounds.size.width - (mediaImageContainerViewLayouts.left + mediaImageContainerViewLayouts.right);
        containerFrame.origin.y = bounds.size.height - (mediaImageHeight + mediaImageContainerViewLayouts.bottom);
        self.mediaImageView.frame = containerFrame;
        
        bottom = bounds.size.height - (self.mediaImageView.frame.origin.y + mediaImageContainerViewLayouts.top);
        
    }
    
    CGRect tweetFrame = self.tweetTextView.frame;
    tweetFrame.size.width = [self tweetTextWidthConstraintWidth:bounds.size.width];
    tweetFrame.size.height = bounds.size.height - (self.characterScreenNameView.frame.origin.y + self.characterScreenNameView.bounds.size.height + characterScreenNameViewLayouts.bottom + bottom);
    self.tweetTextView.frame = tweetFrame;
}

@end

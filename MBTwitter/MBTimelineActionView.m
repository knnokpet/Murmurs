//
//  MBTimelineActionView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineActionView.h"
#import "MBTimelineActionContainerView.h"
#import "MBTimelineActionArrowView.h"
#import "MBTimelineActionButton.h"

#import "MBTweet.h"
#import "MBUserManager.h"
#import "MBUser.h"
#import "MBAccountManager.h"
#import "MBAccount.h"

@interface MBTimelineActionView()

@property (nonatomic) MBTimelineActionContainerView *containerView;
@property (nonatomic) MBTimelineActionArrowView *arrowView;
@property (nonatomic, assign) CGPoint touchedPoint;
@property (nonatomic, assign) CGRect selectedViewFrame;

@end

@implementation MBTimelineActionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithRect:(CGRect)rect atPoint:(CGPoint)point
{
    self = [super init];
    if (self) {
        
        self.alpha = 0;
        
        self.touchedPoint = point;
        self.selectedViewFrame = rect;
    }
    
    return self;
}

#pragma mark - Setter & Getter
- (void)setButtonItems:(NSArray *)buttonItems
{
    _buttonItems = buttonItems;
    
    [self createContainerView];
    [self createArrowView];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    _selectedIndexPath = selectedIndexPath;
}

- (void)setSelectedTweet:(MBTweet *)selectedTweet
{
    _selectedTweet = selectedTweet;
    [self createButtons];
}

#pragma mark Instance Methods
- (void)calculateShowingPosition
{
    MBTimelineActionArrowView *sizingArrowView = self.arrowView;
    MBTimelineActionContainerView *sizingContainerView = self.containerView;
    
    CGRect bouds = CGRectMake(0, 0, sizingContainerView.bounds.size.width, sizingContainerView.bounds.size.height + sizingArrowView.bounds.size.height);
    
    // self.bound,  arrowView, containerView の Y Origin 計算
    CGFloat actionViewheight = sizingArrowView.frame.size.height + sizingContainerView.frame.size.height;
    BOOL isAbove = (self.selectedViewFrame.origin.y - actionViewheight > 0) ? YES : NO;
    
    // ActionView の表示範囲が上に足りない場合は下に表示
    CGFloat showingContainerViewOriginY;
    CGFloat showingArrowViewOriginY;
    if (isAbove) {
        showingContainerViewOriginY = 0;
        showingArrowViewOriginY = sizingContainerView.frame.size.height;
        bouds.origin.y = self.selectedViewFrame.origin.y - (actionViewheight);
    } else {
        showingContainerViewOriginY = sizingArrowView.frame.size.height;
        showingArrowViewOriginY = 0;
        bouds.origin.y = self.selectedViewFrame.origin.y + self.selectedViewFrame.size.height;
    }
    
    BOOL isUpperArrow = (isAbove) ? NO : YES;
    [self.arrowView setIsUpper:isUpperArrow];
    
    
    
    // 自身の限界表示位置
    CGFloat edgeWidth = 10.0f;
    CGFloat showingMyViewOriginX = self.touchedPoint.x - bouds.size.width / 2;
    if (showingMyViewOriginX < edgeWidth) {
        showingMyViewOriginX = edgeWidth;
    } else if ((showingMyViewOriginX + sizingContainerView.frame.size.width) > (self.window.bounds.size.width - edgeWidth)) {
        showingMyViewOriginX = self.window.bounds.size.width - sizingContainerView.frame.size.width - edgeWidth;
    }
    
    bouds.origin.x = showingMyViewOriginX;
    
    
    // arrowView, containerView の X Origin 計算
    CGRect containeRect = self.containerView.frame;
    containeRect.origin = CGPointMake(0, showingContainerViewOriginY);
    self.containerView.frame = containeRect;
    
    
    // arrowView の限界表示位置は、containeView の両端から 10 に調整
    CGFloat showingArrowViewOriginX = bouds.size.width / 2 - sizingArrowView.frame.size.width / 2;
    if (showingArrowViewOriginX < bouds.origin.x) {
        showingArrowViewOriginX = bouds.origin.x + 10.0f;
    } else if (showingArrowViewOriginX + (sizingArrowView.frame.size.width)  > (bouds.origin.x + sizingContainerView.frame.size.width)) {
        showingArrowViewOriginX = (bouds.origin.x + sizingContainerView.frame.size.width) - (sizingArrowView.frame.size.width + 10.0f);
    }
    NSLog(@"arr %f %f", showingArrowViewOriginX, showingArrowViewOriginY);
    CGRect arrowRect = self.arrowView.frame;
    arrowRect.origin = CGPointMake(showingArrowViewOriginX, showingArrowViewOriginY);
    self.arrowView.frame = arrowRect;
    
    self.frame = bouds;
}


- (void)createButtons
{
    // reply
    MBTimelineActionButton *replyButton = [[MBTimelineActionButton alloc] initWithTitle:@"Reply" image:[UIImage imageNamed:@"reply-White"]];
    [replyButton addTarget:self action:@selector(didPushReplyButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    // favorite
    MBTimelineActionButton *favoriteButton = [[MBTimelineActionButton alloc] initWithTitle:@"Favorite" image:[UIImage imageNamed:@"Star-White"]];
    [favoriteButton addTarget:self action:@selector(didPushFavoriteButton) forControlEvents:UIControlEventTouchUpInside];
    if (self.selectedTweet.isFavorited) {
        favoriteButton = [[MBTimelineActionButton alloc] initWithTitle:@"Cancel" image:[UIImage imageNamed:@"Favorite-Cancel-White"]];
        [favoriteButton addTarget:self action:@selector(didPushCancelFavoriteButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // retweet
    MBTimelineActionButton *retweetButton = [[MBTimelineActionButton alloc] initWithTitle:@"Retweet" image:[UIImage imageNamed:@"Retweet-White"]];
    [retweetButton addTarget:self action:@selector(didPushRetweetButton) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.selectedTweet.isRetweeted) {
        retweetButton = [[MBTimelineActionButton alloc] initWithTitle:@"Cancel" image:[UIImage imageNamed:@"Retweet-Cancel-White"]];
        [retweetButton addTarget:self action:@selector(didPushCancelRetweetButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    MBAccount *selectedAccount = [[MBAccountManager sharedInstance] currentAccount];
    if ([self.selectedTweet.tweetUser.userIDStr isEqualToString:selectedAccount.userID] || self.selectedTweet.tweetUser.isProtected) {
        [self setButtonItems:@[replyButton, favoriteButton]];
        return;
    }
    
    
    
    [self setButtonItems:@[replyButton, retweetButton, favoriteButton]];
}

- (void)createContainerView
{
    CGFloat leftSideSpaceWidth = 0.0f;
    CGFloat upSideSpaceWidth = 0.0f;
    CGFloat betweetSpaceWidth = 1.0f;
    
    NSInteger buttonCount = [self.buttonItems count];
    MBTimelineActionButton *sizingButton = [self.buttonItems firstObject];
    CGRect containeRect = CGRectMake(0, 0, (leftSideSpaceWidth * 2) + (sizingButton.frame.size.width * buttonCount) + ((buttonCount - 1) * betweetSpaceWidth), (upSideSpaceWidth * 2) + sizingButton.frame.size.height);
    
    self.containerView = [[MBTimelineActionContainerView alloc] initWithFrame:containeRect];
    
    CGPoint buttonPoint = CGPointMake(leftSideSpaceWidth, upSideSpaceWidth);
    NSInteger buttonIndex = 0;
    for (MBTimelineActionButton *button in self.buttonItems) {
        buttonPoint.x = (sizingButton.frame.size.width * buttonIndex) + leftSideSpaceWidth + (betweetSpaceWidth * (buttonIndex));
        CGRect buttonRect = button.frame;
        buttonRect.origin = buttonPoint;
        button.frame = buttonRect;
        [self.containerView addSubview:button];
        buttonIndex ++;
    }
    
    [self addSubview:self.containerView];
}

- (void)createArrowView
{
    self.arrowView = [[MBTimelineActionArrowView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    self.arrowView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    [self addSubview:self.arrowView];
}

- (void)showViews:(BOOL)shows animated:(BOOL)animated
{
    CGFloat duration = (animated) ? 0.3f : 0.0f;
    
    if (shows) {
        if (animated) {
            duration = 0.1f;
        }
        
        [self calculateShowingPosition];
        [UIView animateWithDuration:duration animations:^{
            self.alpha = 1.0;
        }];
        
    } else {
        [self sendDelegateMethodDismissing];
        
        [UIView animateWithDuration:duration animations:^{
            self.alpha = 0.0;
        }];
        _delegate = nil;
    }
}

- (void)showViews:(BOOL)shows animated:(BOOL)animated inView:(UIView *)view
{
    self.containerView.backgroundView = view;
    [self.containerView updateBlurView];
    /* Arrow のブラーをやめたのでコメントアウト */
    //self.arrowView.backgroundView = view;
    //[self.arrowView updateBlurView];
    [view addSubview:self];
    [self showViews:shows animated:animated];
}

- (void)sendDelegateMethodDismissing
{
    if ([_delegate respondsToSelector:@selector(dismissActionView:)]) {
        [_delegate dismissActionView:self];
    }
}

#pragma mark Action
- (void)didPushReplyButton
{
    if ([_delegate respondsToSelector:@selector(didPushReplyButtonOnActionView:)]) {
        [_delegate didPushReplyButtonOnActionView:self];
    }
    
    [self sendDelegateMethodDismissing];
}

- (void)didPushRetweetButton
{
    if ([_delegate respondsToSelector:@selector(didPushRetweetButtonOnActionView:)]) {
        [_delegate didPushRetweetButtonOnActionView:self];
    }
    
    [self showViews:NO animated:YES];
    [self sendDelegateMethodDismissing];
}

- (void)didPushCancelRetweetButton
{
    if ([_delegate respondsToSelector:@selector(didPushCancelRetweetButtonOnActionView:)]) {
        [_delegate didPushCancelRetweetButtonOnActionView:self];
    }
    
    [self showViews:NO animated:YES];
    [self sendDelegateMethodDismissing];
}

- (void)didPushFavoriteButton
{
    if ([_delegate respondsToSelector:@selector(didPushFavoriteButtonOnActionView:)]) {
        [_delegate didPushFavoriteButtonOnActionView:self];
    }
    
    [self showViews:NO animated:YES];
    [self sendDelegateMethodDismissing];
}

- (void)didPushCancelFavoriteButton
{
    if ([_delegate respondsToSelector:@selector(didPushCancelFavoriteButtonOnActionView:)]) {
        [_delegate didPushCancelFavoriteButtonOnActionView:self];
    }
    
    [self showViews:NO animated:YES];
    [self sendDelegateMethodDismissing];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *touchedView = [super hitTest:point withEvent:event];
    
    if ([touchedView isKindOfClass:[MBTimelineActionButton class]]) {
        
        return touchedView;
    }
    if (touchedView == self) {
        return touchedView;
    }
    
    [self showViews:NO animated:YES];
    return nil;
}

@end

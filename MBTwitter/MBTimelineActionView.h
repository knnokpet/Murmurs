//
//  MBTimelineActionView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBTimelineActionButton.h"

@protocol MBTimelineActionViewDelegate;
@class MBTweet;
@interface MBTimelineActionView : UIView <MBTimelineActionButtonDelegate>

@property (nonatomic, weak) id <MBTimelineActionViewDelegate> delegate;
// action が可能かどうかを判断するために tweet, user オブジェクトが必要。user が requireLoading だったらさらに面倒。
@property (nonatomic, readonly) NSArray *buttonItems;
@property (nonatomic) NSMutableArray *boarders;
@property (nonatomic, readonly) NSIndexPath *selectedIndexPath;
@property (nonatomic, readonly) MBTweet *selectedTweet;

- (instancetype)initWithRect:(CGRect)rect atPoint:(CGPoint)point;

- (void)setButtonItems:(NSArray *)buttonItems;
- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath;
- (void)setSelectedTweet:(MBTweet *)selectedTweet;

- (void)showViews:(BOOL)shows animated:(BOOL)animated;
- (void)showViews:(BOOL)shows animated:(BOOL)animated inView:(UIView *)view;

@end


@protocol MBTimelineActionViewDelegate <NSObject>
- (void)dismissActionView:(MBTimelineActionView *)view;
- (void)didPushReplyButtonOnActionView:(MBTimelineActionView *)view;
- (void)didPushRetweetButtonOnActionView:(MBTimelineActionView *)view;
- (void)didPushFavoriteButtonOnActionView:(MBTimelineActionView *)view;
- (void)didPushCancelRetweetButtonOnActionView:(MBTimelineActionView *)view;
- (void)didPushCancelFavoriteButtonOnActionView:(MBTimelineActionView *)view;

@end
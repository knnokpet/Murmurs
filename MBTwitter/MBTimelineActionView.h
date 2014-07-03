//
//  MBTimelineActionView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBTimelineActionViewDelegate;
@interface MBTimelineActionView : UIView

@property (nonatomic, weak) id <MBTimelineActionViewDelegate> delegate;
// action が可能かどうかを判断するために tweet, user オブジェクトが必要。user が requireLoading だったらさらに面倒。
@property (nonatomic, readonly) NSArray *buttonItems;
@property (nonatomic, readonly) NSIndexPath *selectedIndexPath;

- (instancetype)initWithRect:(CGRect)rect atPoint:(CGPoint)point;

- (void)setButtonItems:(NSArray *)buttonItems;
- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath;

- (void)showViews:(BOOL)shows animated:(BOOL)animated;
- (void)showViews:(BOOL)shows animated:(BOOL)animated inView:(UIView *)view;

@end


@protocol MBTimelineActionViewDelegate <NSObject>
- (void)dismissActionView:(MBTimelineActionView *)view;
- (void)didPushReplyButtonOnActionView:(MBTimelineActionView *)view;
- (void)didPushRetweetButtonOnActionView:(MBTimelineActionView *)view;
- (void)didPushFavoriteButtonOnActionView:(MBTimelineActionView *)view;

@end
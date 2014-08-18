//
//  MBTimelineViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPostTweetViewController.h"
#import "MBDetailTweetViewController.h"
#import "MBDetailUserViewController.h"
#import "MBWebBrowsViewController.h"
#import "MBImageViewController.h"
#import "MBZoomTransitioning.h"

#import "MBTweetViewCell.h"
#import "MBGapedTweetViewCell.h"
#import "MBTweetTextView.h"
#import "MBTimelineActionView.h"
#import "MBLoadingView.h"

#import "MBTwitterAccesser.h"
#import "MBAOuth_TwitterAPICenter.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBTimeLineManager.h"
#import "MBTweetManager.h"
#import "MBUserManager.h"
#import "MBUser.h"
#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"
#import "MBTweetTextComposer.h"
#import "NSString+TimeMargin.h"

#import "MBTwitterAccessibility.h"

#define LINE_SPACING 2.0f
#define LINE_HEIGHT 0.0f
#define PARAGRAPF_SPACING 0.0f
#define FONT_SIZE 15.0f

@class MBTimeLineManager;
@interface MBTimelineViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, MBTwitterAccesserDelegate,MBAOuth_TwitterAPICenterDelegate, MBPostTweetViewControllerDelegate, MBWebBrowsViewControllerDelegate, MBAvatorImageViewDelegate, MBMediaImageViewDelegate, MBTweetTextViewDelegate, MBtweetViewCellLongPressDelegate, MBImageViewControllerDelegate, MBTimelineActionViewDelegate, MBRetweetViewDelegate>

@property (nonatomic) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) MBTimeLineManager *timelineManager;

@property (nonatomic) NSArray *dataSource;
@property (nonatomic, assign) BOOL enableBacking;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) MBLoadingView *loadingView;
@property (nonatomic) UIRefreshControl *refreshControl;

- (void)configureTimelineManager;
- (void)configureNavigationItem;
- (void)configureLoadingView;
- (void)saveTimeline;
- (void)didPushLeftBarButtonItem;
- (void)didPushRightBarButtonItem;
- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max;
- (void)refreshAction;
- (void)refreshMyAccountUser;

- (void)goBacksAtIndex:(NSInteger )index;
- (NSArray *)savedTweetsAtIndex:(NSInteger)index;
- (void)goBackTimelineMaxID:(unsigned long long)max;
- (void)goForwardTimelineSinceID:(unsigned long long)since;
- (void)updateTableViewDataSource:(NSArray *)addingData;

@end

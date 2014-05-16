//
//  MBTimelineViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBDetailTweetViewController.h"

#import "MBTweetViewCell.h"
#import "MBGapedTweetViewCell.h"
#import "MBTweetTextView.h"

#import "MBAOuth_TwitterAPICenter.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBTimeLineManager.h"
#import "MBTweetManager.h"
#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBTweetTextComposer.h"

#import "MBTwitterAccessibility.h"

#define LINE_SPACING 4.0f
#define LINE_HEIGHT 0.0f
#define PARAGRAPF_SPACING 0.0f
#define FONT_SIZE 17.0f

@class MBTimeLineManager;
@interface MBTimelineViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate,MBAOuth_TwitterAPICenterDelegate>

@property (nonatomic) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) MBTimeLineManager *timelineManager;

@property (nonatomic) NSArray *dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIRefreshControl *refreshControl;

- (void)commonConfigureModel;
- (void)commonConfigureView;
- (void)commonConfigureNavigationItem;
- (void)saveTimeline;
- (void)didPushLeftBarButtonItem;
- (void)didPushRightBarButtonItem;
- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max;
//- (void)refreshAction;

- (void)goBacksAtIndex:(NSInteger )index;
- (NSArray *)savedTweetsAtIndex:(NSInteger)index;
- (void)goBackTimelineMaxID:(unsigned long long)max;
- (void)goForwardTimelineSinceID:(unsigned long long)since;
- (void)updateTableViewDataSource:(NSArray *)addingData;

@end

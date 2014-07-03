//
//  MBListViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBLoadingView.h"

#import "MBAOuth_TwitterAPICenter.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBListManager.h"
#import "MBList.h"
#import "MBUserManager.h"
#import "MBUser.h"

@class MBUser;
@interface MBListViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate,UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBUser *user;
@property (nonatomic) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) MBListManager *listManager;
@property (nonatomic) NSNumber *ownershipNextCursor;
@property (nonatomic) NSNumber *subscriveNextCursor;
@property (nonatomic, assign) BOOL enableAdding;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) MBLoadingView *loadingView;

- (void)setUser:(MBUser *)user;

- (void)configureListManager;
- (void)commonConfigureModel;
- (void)commonConfigureView;
- (void)commonConfigureNavigationitem;
- (void)didPushRefreshButton;
- (void)didPushAddListButton;

- (void)goBacksLists;
- (void)updateTableViewDataSource:(NSArray *)addingData;

@end

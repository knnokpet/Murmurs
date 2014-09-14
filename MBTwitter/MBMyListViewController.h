//
//  MBMyListViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListViewController.h"
#import "MBCreateListViewController.h"
#import "MBMyAccountsViewController.h"
#import "MBOwn_ListTimelineManagerViewController.h"
#import "MBOther_ListTimelineManagerViewController.h"

#import "MBNavigationControllerTitleView.h"

@interface MBMyListViewController : MBListViewController <MBCreateListViewControllerDelegate,MBOwn_ListTimelineManagerViewControllerDelegate, MBOther_ListTimelineManagerViewControllerDelegate, MBMyAccountsViewControlerDelegate>

- (void)updateNavigationTitleView;
- (void)setttingMyUser;
- (void)configureLeftNavigationItemWithAnimated:(BOOL)animated;
- (UIBarButtonItem *)backButtonItem;

@end

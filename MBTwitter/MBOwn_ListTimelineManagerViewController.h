//
//  MBOwn_ListTimelineManagerViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListTimelineManagementViewController.h"
#import "MBEditListViewController.h"

@protocol MBOwn_ListTimelineManagerViewControllerDelegate;
@interface MBOwn_ListTimelineManagerViewController : MBListTimelineManagementViewController <MBEditListViewControllerDelegate>

@property (nonatomic, weak) id <MBOwn_ListTimelineManagerViewControllerDelegate> delegate;

@end


@protocol MBOwn_ListTimelineManagerViewControllerDelegate <NSObject>

- (void)deleteListOwn_ListTimelineManagerViewController:(MBOwn_ListTimelineManagerViewController *)controller;
- (void)editListOwn_ListTimelineManagerViewController:(MBOwn_ListTimelineManagerViewController *)controller list:(MBList *)editedList;

@end
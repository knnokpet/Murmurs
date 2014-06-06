//
//  MBOther_ListTimelineManagerViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListTimelineManagementViewController.h"

@protocol MBOther_ListTimelineManagerViewControllerDelegate;
@interface MBOther_ListTimelineManagerViewController : MBListTimelineManagementViewController

@property (nonatomic, weak) id <MBOther_ListTimelineManagerViewControllerDelegate> delegate;

@end


@protocol MBOther_ListTimelineManagerViewControllerDelegate <NSObject>

- (void)subscriveOtherListTimelineManagerViewController:(MBOther_ListTimelineManagerViewController *)controller list: (MBList *)list;
- (void)unsubscriveOtherListTimelineManagerViewController:(MBOther_ListTimelineManagerViewController *)controller;

@end
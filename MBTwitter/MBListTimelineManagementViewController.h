//
//  MBListTimelineManagementViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBListTimelineViewController.h"
#import "MBListMembersViewController.h"

#import "MBAOuth_TwitterAPICenter.h"
#import "MBList.h"
#import "MBUser.h"

@interface MBListTimelineManagementViewController : UIViewController < MBAOuth_TwitterAPICenterDelegate>

@property (nonatomic) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) MBList *list;

@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic) UIViewController *currentController;
@property (nonatomic) MBListTimelineViewController *listTimelineViewController;
@property (nonatomic) MBListMembersViewController *listMembersViewController;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;

- (void)setList:(MBList *)list;
- (void)configureNavigationItem;

@end

//
//  MBSelecting_ListViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListViewController.h"


@protocol MBSelecting_ListViewControllerDelegate;
@interface MBSelecting_ListViewController : MBListViewController

@property (nonatomic, weak) id <MBSelecting_ListViewControllerDelegate> delegate;

@property (nonatomic, readonly) MBUser *selectingUser;
- (void)setSelectingUser:(MBUser *)selectingUser;

@end


@protocol MBSelecting_ListViewControllerDelegate <NSObject>

- (void)cancelSelectingListViewController:(MBSelecting_ListViewController *)controller animated:(BOOL)animated;
- (void)doneSelectingListViewController:(MBSelecting_ListViewController *)controller animated:(BOOL)animated;

@end
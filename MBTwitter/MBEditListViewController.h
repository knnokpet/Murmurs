//
//  MBEditListViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBCreateListViewController.h"
#import "MBListMembersViewController.h"

@class MBList;
@protocol MBEditListViewControllerDelegate;
@interface MBEditListViewController : MBCreateListViewController <UIActionSheetDelegate, MBListMembersViewControllerDelegate>

@property (nonatomic, weak) id <MBEditListViewControllerDelegate> editDelegate;
@property (nonatomic, readonly) MBList *list;

- (void)setList:(MBList *)list;

@end


@protocol MBEditListViewControllerDelegate <NSObject>

- (void)deleteListEditListViewController:(MBEditListViewController *)controller;
- (void)editListEditListViewController:(MBEditListViewController *)controller list:(MBList *)edetedList;
- (void)dismissEditListViewController:(MBEditListViewController *)controller;

@end
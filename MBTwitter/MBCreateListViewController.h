//
//  MBCreateListViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"
#import "MBList.h"

#import "MBTextFieldTableViewCell.h"
#import "MBSwitchTableViewCell.h"

static NSString *textFieldCellIdentifier = @"TextFieldCellIdentifier";
static NSString *switchCellIdentifier = @"SwitchCellIdentifier";

@protocol MBCreateListViewControllerDelegate;
@class MBList;
@interface MBCreateListViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate ,UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id <MBCreateListViewControllerDelegate> delegate;
@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

- (BOOL)checksListName:(NSString *)listName;
- (void)commonConfigureNavigationItem;
- (void)updateCell:(UITableViewCell *)cell atIndexpath:(NSIndexPath *)indexPath;

@end



@protocol MBCreateListViewControllerDelegate <NSObject>

- (void)dismissCreateListViewController:(MBCreateListViewController *)controller animated:(BOOL)animated;
- (void)createListViewController:(MBCreateListViewController *)controller withList:(MBList *)list;

@end
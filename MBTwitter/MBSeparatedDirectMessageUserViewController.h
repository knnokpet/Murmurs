//
//  MBSeparatedDirectMessageUserViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBIndividualDirectMessagesViewController.h"
#import "MBAOuth_TwitterAPICenter.h"
#import "MBMyAccountsViewController.h"

@interface MBSeparatedDirectMessageUserViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate, MBIndividualDirectMessagesViewControllerDelegate, MBMyAccountsViewControlerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) UIRefreshControl *refreshControl;

@end

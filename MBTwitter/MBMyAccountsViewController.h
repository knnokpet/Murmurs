//
//  MBMyAccountsViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAuthorizationViewController.h"
#import "MBAOuth_TwitterAPICenter.h"

@protocol MBMyAccountsViewControlerDelegate;
@class MBTwitterAccesser;
@interface MBMyAccountsViewController : UIViewController <MBAuthorizationViewControllerDelegate, MBAOuth_TwitterAPICenterDelegate>

@property (nonatomic) MBTwitterAccesser *twitterAccessor;
@property (nonatomic, weak) id <MBMyAccountsViewControlerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end



@protocol MBMyAccountsViewControlerDelegate <NSObject>

- (void)dismissAccountsViewController:(MBMyAccountsViewController *)controller animated:(BOOL)animated;

@end
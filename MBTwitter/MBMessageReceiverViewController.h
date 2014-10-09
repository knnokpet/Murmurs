//
//  MBMessageReceiverViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBMessageReceiverViewControllerDelegate;
@class MBUser;
@interface MBMessageReceiverViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *dataSource;
@property (nonatomic) NSString *inputedString;

@property (nonatomic, weak) id <MBMessageReceiverViewControllerDelegate> delegate;

@end



@protocol MBMessageReceiverViewControllerDelegate <NSObject>

- (void)selectReceiverViewController:(MBMessageReceiverViewController *)controller user:(MBUser *)user;
- (void)selectSearchReceiverViewController:(MBMessageReceiverViewController *)controller;

@end
//
//  MBUsersViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"
#import "MBUser.h"
#import "MBAvatorImageView.h"

@interface MBUsersViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) MBUser *user;
@property (nonatomic, readonly) NSMutableArray *users;
@property (nonatomic) NSNumber *nextCursor;
@property (nonatomic) NSNumber *previousCursor;

@property (nonatomic, assign) BOOL enableAdding;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)setUser:(MBUser *)user;

- (void)configureModel;
- (void)configureView;
- (void)configureNavigationItem;

- (void)backUsersAtCursor:(long long)cursor;
- (NSArray *)decorateAddingArray:(NSArray *)addingArray;
- (void)updateTableViewDataSource:(NSArray *)addingArray;
- (void)removeBackTimelineIndicatorView;

@end

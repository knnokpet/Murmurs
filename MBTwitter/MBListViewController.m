//
//  MBListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListViewController.h"
#import "MBListTimelineManagementViewController.h"

@interface MBListViewController ()


@end

@implementation MBListViewController
#pragma mark -
#pragma mark Initialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setUser:(MBUser *)user
{
    _user = user;
    _listManager.owner = user;
}

#pragma mark -
#pragma mark View
- (void)configureListManager
{
    _listManager = [[MBListManager alloc] init];
}

- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    [self configureListManager];
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationitem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    /* remove nonContent's separator */
    UIView *view = [[UIView alloc] init];
    view.backgroundColor  = [UIColor clearColor];
    [self.tableView setTableHeaderView:view];
    [self.tableView setTableFooterView:view];
    
    _loadingView = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
    //[self.view insertSubview:self.loadingView aboveSubview:self.tableView];
    
    self.enableAdding = NO;
    self.ownershipNextCursor = [NSNumber numberWithInt:-1];
    self.subscriveNextCursor = [NSNumber numberWithInt:-1];
}

- (void)commonConfigureNavigationitem
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self commonConfigureModel];
    [self commonConfigureView];
    [self commonConfigureNavigationitem];
    
    [self goBacksLists];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)goBacksLists
{
    [self backOwnerLists];
    [self backSubscriveLists];
    
}

- (void)backOwnerLists
{
    long long cursor = [self.ownershipNextCursor longLongValue];
    if (0 == cursor) {
        return;
    } else {
        [self.aoAPICenter getListsOfOwnerShipWithUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName cursor:cursor];
    }
}

- (void)backSubscriveLists
{
    long long cursor = [self.ownershipNextCursor longLongValue];
    if (0 == cursor) {
        return;
    } else {
        [self.aoAPICenter getListsOfSubscriptionWithUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName cursor:cursor];
    }
}

#pragma mark Action
- (void)didPushRefreshButton
{
    
}

- (void)didPushAddListButton
{
    
}


#pragma mark -
#pragma mark UITableView Datasource & Delegate
- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 0;
    if (0 < self.listManager.ownerShipLists.count) {
        sectionCount ++;
    }
    if (0 < self.listManager.subscriptionLists.count) {
        sectionCount ++;
    }
    
    return sectionCount;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *listsAtIndex = [self.listManager.lists objectAtIndex:section];
    return [listsAtIndex count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    NSString *headername;
    if (NSOrderedSame == [currentAccount.userID compare:self.user.userIDStr]) {
        if (0 == section) {
            headername = NSLocalizedString(@"Your List" , nil);
        } else {
            headername = NSLocalizedString(@"Your Subscriving List", nil);
        }
        
    } else {
        if (0 == section) {
            NSString *ownersList = NSLocalizedString(@" 's List", nil);
            headername = [NSString stringWithFormat:@"%@%@", self.user.characterName, ownersList];
        } else {
            NSString *subscrivingString = NSLocalizedString(@" 's Subscriving List", nil);
            headername = [NSString stringWithFormat:@"%@%@", self.user.characterName, subscrivingString];
        }
    }
    
    if (0 == [(NSArray *)[self.listManager.lists objectAtIndex:section] count]) {
        headername = nil;
    }
    
    return headername;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
    MBList *listAtIndex = [listsAtSection objectAtIndex:indexPath.row];
    cell.textLabel.text = listAtIndex.name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)updateTableViewDataSource:(NSArray *)addingData
{
    
    if (0 == [addingData count]) {
        ;
    } else {
        [self.listManager addLists:addingData];
        [self.tableView reloadData];
    }
    self.enableAdding = YES;
    
    if (0 != [self.ownershipNextCursor longLongValue] || 0 != [self.subscriveNextCursor longLongValue] ) {
        [self goBacksLists];
    }
    
    // ラウンチ時に表示されている UIActivityView を remove
    if (self.loadingView.superview) {
        [UIView animateWithDuration:1.0f animations:^{
            [self.loadingView setHidden:YES];
        }completion:^(BOOL finished){
            [self.loadingView removeFromSuperview];
            _loadingView = nil;
        }];
    }
    
}

#pragma mark AOuth_APICenter Delegate

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedLists:(NSArray *)lists next:(NSNumber *)next previous:(NSNumber *)previous
{
    if (!lists || !next || !previous) {
        return;
    }
    
    NSLog(@"count = %d", [lists count]);
    MBList *addingList = [lists firstObject];
    if (!addingList) {
        return ;
    }
    MBUser *ownerOfList = addingList.user;
    if (!ownerOfList) {
        return;
    }
    
    if (NSOrderedSame == [self.user.userID compare:ownerOfList.userID]) {
        self.ownershipNextCursor = next;
    } else {
        self.subscriveNextCursor = next;
    }
    
    [self updateTableViewDataSource:lists];
}

@end

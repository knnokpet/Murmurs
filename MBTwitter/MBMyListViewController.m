//
//  MBMyListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMyListViewController.h"


@interface MBMyListViewController ()

@property (nonatomic) NSMutableArray *dataSouece;

@end

@implementation MBMyListViewController
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
#pragma mark View
- (void)commonConfigureNavigationitem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didPushRefreshButton)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self receiveChangedAccountNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setttingMyUser];
}

- (void)setttingMyUser
{
    MBAccount *currentAccount;
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount]) {
        currentAccount = [[MBAccountManager sharedInstance] currentAccount];
        MBUser *myUser = [[MBUserManager sharedInstance] storedUserForKey:currentAccount.userID];
        [self setUser:myUser];
        
        if (!self.user) {
            [self.aoAPICenter getUser:0 screenName:currentAccount.screenName];
        }
    }
}

- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSLog(@"user change account to = %@", [[MBAccountManager sharedInstance] currentAccount].screenName);
        self.aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        self.aoAPICenter.delegate = self;
        self.listManager = [[MBListManager alloc] init];
        [self.tableView reloadData];
        
        [self setttingMyUser];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Method

- (BOOL)reachsTheLimitOfList
{
    BOOL reachs = NO;
    if (20 > [self.listManager.lists count]) {
        return reachs;
    }
    
    MBAccount *currentAccount;
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount]) {
        currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    }
    NSInteger count = 0;
    for (MBList *list in self.listManager.lists) {
        if (count == 20) {
            reachs = YES;
            break;
        }
        
        if ([list.user.userIDStr isEqualToString:currentAccount.userID]) {
            count++;
        }
    }
    
    return reachs;
}

#pragma mark Action
- (void)didPushAddListButton
{
    if ([self reachsTheLimitOfList]) {
        NSLog(@"リストの限界に達しています");
    }
    
    MBCreateListViewController *createListViewController = [[MBCreateListViewController alloc] init];
    createListViewController.delegate = self;
    UINavigationController *createListNavigationController = [[UINavigationController alloc] initWithRootViewController:createListViewController];
    [self.navigationController presentViewController:createListNavigationController animated:YES completion:nil];
    
}

- (void)didPushRefreshButton
{
    
}

#pragma mark -
#pragma mark TableView Delegate Datasource
#pragma mark Edit TableView
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (YES == editing) {
        UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPushAddListButton)];
        [self.navigationItem setLeftBarButtonItem:addBarButtonItem animated:animated];
    } else {
        UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didPushRefreshButton)];
        [self.navigationItem setLeftBarButtonItem:refreshBarButtonItem animated:animated];
    }
    
    [self.tableView setEditing:editing animated:YES];
    [super setEditing:editing animated:animated];
}


- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *selectedArrayAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
        MBList *selectedList = [selectedArrayAtSection objectAtIndex:indexPath.row];
        if (0 == indexPath.section) {
            [self.aoAPICenter postDestroyOwnList:[selectedList.listID unsignedLongLongValue] slug:selectedList.slug ownerScreenName:selectedList.user.screenName ownerID:[selectedList.user.userID unsignedLongLongValue]];
            [self.listManager removeListOfOwner:indexPath.row];
        } else {
            [self.aoAPICenter postDestroySubscrivedList:[selectedList.listID unsignedLongLongValue] slug:selectedList.slug ownerScreenName:selectedList.user.screenName ownerID:[selectedList.user.userID unsignedLongLongValue]];
            [self.listManager removeListOfSubscrive:indexPath.row];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

#pragma mark Datasource

#pragma mark - Navigation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
    MBList *selectedList = [listsAtSection objectAtIndex:indexPath.row];
    MBListTimelineManagementViewController *listTimelineManagerViewController;
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    if ([selectedList.user.userIDStr isEqualToString:currentAccount.userID]) {
        MBOwn_ListTimelineManagerViewController *ownController = [[MBOwn_ListTimelineManagerViewController alloc] initWithNibName:@"MBListTimelineManagementViewController" bundle:nil];
        ownController.delegate = self;
        listTimelineManagerViewController = ownController;
    } else {
        MBOther_ListTimelineManagerViewController *otherController = [[MBOther_ListTimelineManagerViewController alloc] initWithNibName:@"MBListTimelineManagementViewController" bundle:nil];
        otherController.delegate = self;
        listTimelineManagerViewController = otherController;
    }
    
    [listTimelineManagerViewController setList:selectedList];
    
    [self.navigationController pushViewController:listTimelineManagerViewController animated:YES];
}
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark CreateListViewController Delegate
- (void)dismissCreateListViewController:(MBCreateListViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}


- (void)createListViewController:(MBCreateListViewController *)controller withList:(MBList *)list
{
    [self.listManager.ownerShipLists insertObject:list atIndex:0];
    [self.tableView reloadData];
}

#pragma mark AouthAPICenter
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users
{
    MBUser *myUser = [users firstObject];
    if (myUser) {
        [self setUser:myUser];
        [self goBacksLists];
    }
}

#pragma makr OwnListTimelineViewCOntrollerDelegate
- (void)deleteListOwn_ListTimelineManagerViewController:(MBOwn_ListTimelineManagerViewController *)controller
{
    NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    [self.listManager removeListOfOwner:selectedIndex.row];
    [self.tableView reloadData];
    
}

- (void)editListOwn_ListTimelineManagerViewController:(MBOwn_ListTimelineManagerViewController *)controller list:(MBList *)editedList
{
    NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    [self.listManager removeListOfOwner:selectedIndex.row];
    [self.listManager.ownerShipLists insertObject:editedList atIndex:0];
    [self.tableView reloadData];
    
}

#pragma mark OtherListTimelineViewControllerDelegate
- (void)subscriveOtherListTimelineManagerViewController:(MBOther_ListTimelineManagerViewController *)controller list:(MBList *)list
{
    [self.listManager.subscriptionLists insertObject:list atIndex:0];
    [self.tableView reloadData];
}

- (void)unsubscriveOtherListTimelineManagerViewController:(MBOther_ListTimelineManagerViewController *)controller
{
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    [self.listManager removeListOfSubscrive:selectedPath.row];
    [self.tableView reloadData];
}

@end

//
//  MBOtherUserListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBOtherUserListViewController.h"


@interface MBOtherUserListViewController ()

@end

@implementation MBOtherUserListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark -View
- (void)commonConfigureNavigationitem
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.user) {
        [self goBacksLists];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -InstanceMethods
- (void)configureReloadButton
{
    self.resultView.requireReloadButton = NO;
}

#pragma mark - Navigation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
    MBList *selectedList = [listsAtSection objectAtIndex:indexPath.row];
    MBOther_ListTimelineManagerViewController *listTimelineManagerViweController = [[MBOther_ListTimelineManagerViewController alloc] initWithNibName:@"MBListTimelineManagementViewController" bundle:nil];
    listTimelineManagerViweController.delegate = self;
    [listTimelineManagerViweController setList:selectedList];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    NSString *localizedString = NSLocalizedString(@"@%@'s List", nil);
    backButtonItem.title = [NSString stringWithFormat:localizedString, self.user.screenName];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    [self.navigationController pushViewController:listTimelineManagerViweController animated:YES];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Other_ListTimelineManagerViewController Delegate
- (void)replacePreservedListWithNewList:(MBList *)list
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    NSMutableArray *listsAtSection = [self.listManager.lists objectAtIndex:selectedIndexPath.section];
    MBList *selectedList = [listsAtSection objectAtIndex:selectedIndexPath.row];
    if ([selectedList.listID compare:list.listID] == NSOrderedSame) {
        [listsAtSection replaceObjectAtIndex:selectedIndexPath.row withObject:list];
    }
}

- (void)subscriveOtherListTimelineManagerViewController:(MBOther_ListTimelineManagerViewController *)controller list:(MBList *)list
{
    [self replacePreservedListWithNewList:list];
    
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    if (currentAccount) {
        MBListManager *currentListManager = currentAccount.listManager;
        [currentListManager addLists:@[list]];
    }
}

- (void)unsubscriveOtherListTimelineManagerViewController:(MBOther_ListTimelineManagerViewController *)controller list:(MBList *)list
{
    [self replacePreservedListWithNewList:list];
    
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    if (currentAccount) {
        MBListManager *currentListManager = currentAccount.listManager;
        [currentListManager removeListOfSubscriveWithList:list];
    }
}

@end

//
//  MBOtherUserListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBOtherUserListViewController.h"
#import "MBOther_ListTimelineManagerViewController.h"

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
        [self.listManager setOwner:self.user];
        [self.aoAPICenter getListsOfUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -InstanceMethods


#pragma mark - Navigation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
    MBList *selectedList = [listsAtSection objectAtIndex:indexPath.row];
    MBOther_ListTimelineManagerViewController *listTimelineManagerViweController = [[MBOther_ListTimelineManagerViewController alloc] initWithNibName:@"MBListTimelineManagementViewController" bundle:nil];
    [listTimelineManagerViweController setList:selectedList];
    
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

@end

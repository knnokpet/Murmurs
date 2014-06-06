//
//  MBOwn_ListTimelineManagerViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBOwn_ListTimelineManagerViewController.h"

@interface MBOwn_ListTimelineManagerViewController ()

@end

@implementation MBOwn_ListTimelineManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureNavigationItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didPushEditNavigationBarItem)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPushEditNavigationBarItem
{
    MBEditListViewController *editListViewController = [[MBEditListViewController alloc] initWithNibName:@"MBCreateListViewController" bundle:nil];
    editListViewController.editDelegate = self;
    [editListViewController setList:self.list];
    UINavigationController *editListNavigatioNController = [[UINavigationController alloc] initWithRootViewController:editListViewController];
    [self.navigationController presentViewController:editListNavigatioNController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark EditListViewController Delegate
- (void)dismissEditListViewController:(MBEditListViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)editListEditListViewController:(MBEditListViewController *)controller list:(MBList *)edetedList
{
    if ([_delegate respondsToSelector:@selector(editListOwn_ListTimelineManagerViewController:list:)]) {
        [_delegate editListOwn_ListTimelineManagerViewController:self list:edetedList];
    }
    
    self.list = edetedList;
    [self.listTimelineViewController.tableView reloadData];
    [self.listMembersViewController.tableView reloadData];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteListEditListViewController:(MBEditListViewController *)controller
{
    if ([_delegate respondsToSelector:@selector(deleteListOwn_ListTimelineManagerViewController:)]) {
        [_delegate deleteListOwn_ListTimelineManagerViewController:self];
    }
    [self.navigationController popViewControllerAnimated:NO];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

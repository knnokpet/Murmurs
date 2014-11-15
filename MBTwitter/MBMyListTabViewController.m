//
//  MBMyListTabViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMyListTabViewController.h"

@interface MBMyListTabViewController ()

@end

@implementation MBMyListTabViewController

- (void)configureLeftNavigationItemWithAnimated:(BOOL)animated
{
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushAccountButton)] animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self receiveChangedAccountNotification];
}

- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        self.aoAPICenter.delegate = nil;
        self.aoAPICenter = nil;
        [self commonConfigureModel];
        [self commonConfigureView];
        [self setttingMyUser];
        [self updateNavigationTitleView];
        
        [self.tableView reloadData];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateNavigationTitleView
{
    MBNavigationControllerTitleView *titleView = [[MBNavigationControllerTitleView alloc] initWithFrame:CGRectZero];
    [titleView setTitle:NSLocalizedString(@"List", nil)];
    [titleView sizeToFit];
    [self.navigationItem setTitleView:titleView];
}

- (void)didPushAccountButton
{
    MBMyAccountsViewController *accountViewController = [[MBMyAccountsViewController alloc] initWithNibName:@"MyAccountView" bundle:nil];
    accountViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIBarButtonItem *)backButtonItem
{
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = NSLocalizedString(@"List", nil);
    return backButtonItem;
}

@end

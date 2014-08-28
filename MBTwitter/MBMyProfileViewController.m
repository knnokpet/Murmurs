//
//  MBMyProfileViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMyProfileViewController.h"

#import "MBUserTimelineViewController.h"
#import "MBFollowingViewController.h"
#import "MBFollowerViewController.h"
#import "MBFavoritesViewController.h"
#import "MBMyListViewController.h"

#import "MBNavigationControllerTitleView.h"

@interface MBMyProfileViewController ()

@end

@implementation MBMyProfileViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(didPushTweetButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushAccountButton)];
}

- (void)configureNavigationTitleView
{
    MBNavigationControllerTitleView *titleView = [[MBNavigationControllerTitleView alloc] initWithFrame:CGRectZero];
    [titleView setTitle:NSLocalizedString(@"MyProfile", nil)];
    [titleView sizeToFit];
    [self.navigationItem setTitleView:titleView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureNavigationTitleView];
    
    self.title = NSLocalizedString(@"MyProfile", nil);
    [self configureNavigationItem];
    [self receiveChangedAccountNotification];
}

- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSLog(@"user change account to = %@ in Profile", [[MBAccountManager sharedInstance] currentAccount].screenName);
        [self configureUserObject];
        [self configureModel];
        [self updateViews];
    }];
}

- (void)configureUserObject
{
    MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    MBUser *myUser = [[MBUserManager sharedInstance] storedUserForKey:currentAccount.userID];
    [self setUser:myUser];
    
    if (!self.user) {
        [self.aoAPICenter getUser:0 screenName:currentAccount.screenName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark InstanceMethods
- (void)didPushAccountButton
{
    MBMyAccountsViewController *accountViewController = [[MBMyAccountsViewController alloc] initWithNibName:@"MyAccountView" bundle:nil];
    accountViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushTweetButton
{
    MBPostTweetViewController *postTweetViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postTweetViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postTweetViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        return;
    }
    
    NSInteger row = indexPath.row;
    if (0 == row) {
        MBUserTimelineViewController *userTimelineViewController = [[MBUserTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
        userTimelineViewController.user = self.user;
        [self.navigationController pushViewController:userTimelineViewController animated:YES];
        
    } else if (1 == row) {
        MBFollowingViewController *followingViewController = [[MBFollowingViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
        [followingViewController setUser:self.user];
        [self.navigationController pushViewController:followingViewController animated:YES];
        
    } else if (2 == row) {
        MBFollowerViewController *followerViewController = [[MBFollowerViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
        [followerViewController setUser:self.user];
        [self.navigationController pushViewController:followerViewController animated:YES];
        
    } else if (3 == row) {
        MBFavoritesViewController *favoritesViewController = [[MBFavoritesViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
        [favoritesViewController setUser:self.user];
        [self.navigationController pushViewController:favoritesViewController animated:YES];
        
    } else if (4 == row) {
        MBMyListViewController *myListViewController = [[MBMyListViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
        [self.navigationController pushViewController:myListViewController animated:YES];
    }
}

#pragma mark - Delegate
#pragma mark MBMyAccountViewController Delegate
- (void)dismissAccountsViewController:(MBMyAccountsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
    controller = nil;
}


@end

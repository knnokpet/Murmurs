//
//  MBHomeTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/02.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBHomeTimelineViewController.h"

@interface MBHomeTimelineViewController ()

@end

@implementation MBHomeTimelineViewController
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

- (void)configureTimelineManager
{
    MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    self.timelineManager = currentAccount.timelineManager;
    self.dataSource = self.timelineManager.tweets;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[MBAccountManager sharedInstance] currentAccount].screenName;
    
   [self refreshMyAccountUser];
    
    [self receiveChangedAccountNotification];
}

- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSLog(@"user change account to = %@", [[MBAccountManager sharedInstance] currentAccount].screenName);
        MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
        self.title = currentAccount.screenName;
        self.timelineManager = currentAccount.timelineManager;
        self.dataSource = self.timelineManager.tweets;
        self.aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        self.aoAPICenter.delegate = self;
        [self.tableView reloadData];
        
        // アカウントを変更すると保存されていたものが再び読み込まれてしまうぞ
        if (0 == self.dataSource.count) {
            [self goBacksAtIndex:0];
        } else {
            [self refreshAction];
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)saveTimeline
{
    NSArray *saveTweets = self.dataSource;
    [[MBTweetManager sharedInstance] saveTimeline:saveTweets];
}

- (NSArray *)savedTweetsAtIndex:(NSInteger)index
{
    NSArray *savedTweets = [[MBTweetManager sharedInstance] savedTimelineAtIndex:index];
    return savedTweets;
}

- (void)goBackTimelineMaxID:(unsigned long long)max
{
    [self.aoAPICenter getBackHomeTimeLineMaxID:max];
}

- (void)refreshMyAccountUser
{
    NSLog(@"refresh myaccount");
    NSArray *accounts = [[MBAccountManager sharedInstance] accounts];
    if (0 == accounts.count) {
        return;
    }
    
    NSMutableArray *accountIDs = [NSMutableArray array];
    NSNumberFormatter *numberFormetter = [[NSNumberFormatter alloc] init];
    for (MBAccount *account in accounts) {
        NSNumber *accountID = [numberFormetter numberFromString:account.userID];
        [accountIDs addObject:accountID];
    }
    [self.aoAPICenter getUsersLookupUserIDs:accountIDs];
}

#pragma mark Action
- (void)didPushLeftBarButtonItem
{
    MBMyAccountsViewController *accountViewController = [[MBMyAccountsViewController alloc] initWithNibName:@"MyAccountView" bundle:nil];
    accountViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushRightBarButtonItem
{
    
    MBPostTweetViewController *postTweetViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postTweetViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postTweetViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max
{
    [self.aoAPICenter getHomeTimeLineSinceID:since maxID:max];
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    [self.aoAPICenter getForwardHomeTimeLineSinceID:since];
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

#pragma mark -
#pragma mark Delegate
#pragma mark MyAccountViewController
- (void)dismissAccountsViewController:(MBMyAccountsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
    controller = nil;
}

#pragma mark PostTweetViewController
- (void)dismissPostTweetViewController:(MBPostTweetViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)sendTweetPostTweetViewController:(MBPostTweetViewController *)controller
{
    [self refreshAction];
}

#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users
{
    NSLog(@"user count = %d", users.count);
}

@end

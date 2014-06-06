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
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[MBAccountManager sharedInstance] currentAccount].screenName;
    
    [self receiveChangedAccountNotification];
}

- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSLog(@"user change account to = %@", [[MBAccountManager sharedInstance] currentAccount].screenName);
        self.title = [[MBAccountManager sharedInstance] currentAccount].screenName;
        self.timelineManager = [[MBTimeLineManager alloc] init];
        self.dataSource = self.timelineManager.tweets;
        self.aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        self.aoAPICenter.delegate = self;
        [self.tableView reloadData];
        [self goBacksAtIndex:0];
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
        [self refreshAction];
    }];
}

@end

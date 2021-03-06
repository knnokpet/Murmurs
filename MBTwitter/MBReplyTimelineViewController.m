//
//  MBReplyTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBReplyTimelineViewController.h"

#import "MBNavigationControllerTitleView.h"

@interface MBReplyTimelineViewController ()

@end

@implementation MBReplyTimelineViewController
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark View

- (void)configureTimelineManager
{
    MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    self.timelineManager = currentAccount.replyTimelineManager;
    self.dataSource = self.timelineManager.tweets;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateNavigationTitleView];
    
    [self receiveChangedAccountnotification];
}

- (void)receiveChangedAccountnotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self updateNavigationTitleView];
        [self configureTimelineManager];
        self.aoAPICenter.delegate = nil;
        self.aoAPICenter = nil;
        self.aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        self.aoAPICenter.delegate = self;
        self.enableBacking = YES;
        self.requireUpdatingDatasource = NO;
        [self configureBackTimelineIndicatorView];
        [self.tableView reloadData];
        [self.tableView setContentOffset:self.timelineManager.currentOffset];
        if (0 == self.dataSource.count) {
            [self goBacksAtIndex:0];
        } else {
            [self refreshAction];
        }
    }];
}

- (NSArray *)savedTweetsAtIndex:(NSInteger)index
{
    NSArray *savedTweets = [[MBTweetManager sharedInstance] savedReplyAtIndex:index];
    return savedTweets;
}

- (void)goBackTimelineMaxID:(unsigned long long)max
{
    [self.aoAPICenter getBackReplyTimelineMaxID:max];
}

#pragma mark -
#pragma mark Instance Methods
- (void)updateNavigationTitleView
{
    MBNavigationControllerTitleView *titleView = [[MBNavigationControllerTitleView alloc] initWithFrame:CGRectZero];
    [titleView setTitle:NSLocalizedString(@"@Tweet", nil)];
    [titleView sizeToFit];
    [self.navigationItem setTitleView:titleView];
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
    [self.aoAPICenter getReplyTimelineSinceID:since maxID:max];
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    [self.aoAPICenter getForwardReplyTimelineSinceID:since];
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

- (UIBarButtonItem *)backButtonItem
{
    UIBarButtonItem *backButtonitem = [[UIBarButtonItem alloc] init];
    backButtonitem.title = NSLocalizedString(@"@Tweet", nil);
    return backButtonitem;
}

#pragma mark -
#pragma mark Delegate
#pragma mark MyAccountViewController
- (void)dismissAccountsViewController:(MBMyAccountsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
    controller = nil;
}

@end

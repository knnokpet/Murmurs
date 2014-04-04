//
//  MBViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBViewController.h"

#import "MBTweetViewCell.h"
#import "MBTweetTextView.h"

#import "MBAOuth_TwitterAPICenter.h"
#import "MBTwitterAccesser.h"
#import "MBAccountManager.h"
#import "MBAccount.h"


@interface MBViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) MBTwitterAccesser *twitterAccesser;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *accountButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;

@end

@implementation MBViewController

#pragma mark -
#pragma mark View

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChangeMyAccountNotification:) name:@"ChangeMyAccount" object:nil];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount] ) {
        self.title = [[MBAccountManager sharedInstance] currentAccount].screenName;
        _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        [_aoAPICenter getHomeTimeLineSinceID:0 maxID:0];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Action

- (IBAction)didPushAccountButton:(id)sender {
    [self performSegueWithIdentifier:@"AccountsIdentifier" sender:self];
}
- (IBAction)didPushTweetButton:(id)sender {
    [self performSegueWithIdentifier:@"PostTweetIdentifier" sender:self];
}

#pragma mark -
#pragma mark StoryBoard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (YES == [[segue identifier] isEqualToString:@"AccountsIdentifier"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        MBMyAccountsViewController *accountViewController = (MBMyAccountsViewController *)navigationController.topViewController;
        accountViewController.delegate = self;
    } else if (YES == [[segue identifier] isEqualToString:@"PostTweetIdentifier"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        MBPostTweetViewController *postTweetViewController = (MBPostTweetViewController *)navigationController.topViewController;
        postTweetViewController.delegate = self;
    }
}

#pragma mark -
#pragma mark TableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdenrifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdenrifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenrifier];
    }
    
    return cell;
}

- (void)updateCell:(MBTweetViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark AccountsViewController Delegate
- (void)dismissAccountsViewController:(MBMyAccountsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark -
#pragma mark Notifiation
- (void)receiveChangeMyAccountNotification:(NSNotification *)notification
{
    OAToken *accessToken = [[MBAccountManager sharedInstance] currentAccount].accessToken;
    self.twitterAccesser = [[MBTwitterAccesser alloc] initWithAccessToken:accessToken];
}

@end

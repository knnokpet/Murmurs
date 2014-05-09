//
//  MBMyAccountsViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMyAccountsViewController.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBTwitterAccesser.h"
#import "MBUser.h"

@interface MBMyAccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) NSArray *accounts;

@end

@implementation MBMyAccountsViewController
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
- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^ (NSNotification *notification) {
        _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        _aoAPICenter.delegate = self;
        [_aoAPICenter getUser:0 screenName:[MBAccountManager sharedInstance].currentAccount.screenName];
    }];
    
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)commonConfigureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didPushCloseButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New Account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushAccountButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonConfigureModel];
    [self commonConfigureView];
    
    [self.twitterAccessor isAuthorized];
    
    self.accounts = [MBAccountManager sharedInstance].accounts;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)requestAccessForDeviceAccount
{
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (accountManager == nil) {
        
    }
    
    [accountManager requestAccessToAccountWithCompletionHandler:^(BOOL granted, NSArray *accounts, NSError *error) {
        if (!granted) {
            return;
        }
        
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^(){
            for (ACAccount *account in accounts) {
                [self.twitterAccessor requestReverseRequestTokenWithAccount:account];
            }
        });
        
    }];
}



#pragma mark -
#pragma mark Button Action

- (void)didPushCloseButton
{
    if ([_delegate respondsToSelector:@selector(dismissAccountsViewController:animated:)]) {
        [_delegate dismissAccountsViewController:self animated:YES];
    }
}

- (void)didPushAccountButton
{
    MBAuthorizationViewController *authorizationViewController = [[MBAuthorizationViewController alloc] initWithNibName:@"AuthorizationView" bundle:nil];
    authorizationViewController.delegate = self;
    MBTwitterAccesser *newAccesser = [[MBTwitterAccesser alloc] init];
    authorizationViewController.twitterAccesser = newAccesser;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authorizationViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushDeleteButton
{
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    [accountManager deleteAllAccount];
    self.accounts = [MBAccountManager sharedInstance].accounts;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView DataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBAccount *account = [self.accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = account.screenName;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[MBAccountManager sharedInstance] selectAccountAtIndex:indexPath.row];
}

#pragma mark - 
#pragma mark AuthorizationViewController Delegate
- (void)dismissAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

- (void)succeedAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    NSInteger lastIndex = [[MBAccountManager sharedInstance].accounts count] - 1;
    [[MBAccountManager sharedInstance] selectAccountAtIndex:lastIndex];
    
    [self.tableView reloadData];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users
{
    MBUser *user = [users firstObject];
    NSLog(@"%@ count = %d", user.userIDStr, user.tweetCount);
}

@end

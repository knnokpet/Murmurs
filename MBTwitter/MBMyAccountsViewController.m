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

@interface MBMyAccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *accounts;

// View
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *accountButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteAccount;

@end

@implementation MBMyAccountsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.twitterAccessor isAuthorized];
    
    self.accounts = [MBAccountManager sharedInstance].accounts;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.accounts count] != [[MBAccountManager sharedInstance].accounts count]) {
        self.accounts = [MBAccountManager sharedInstance].accounts;
        [self.tableView reloadData];
    }
}

// 
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Button Action

- (IBAction)didPushCloseButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(dismissAccountsViewController:animated:)]) {
        [_delegate dismissAccountsViewController:self animated:YES];
    }
}

- (IBAction)didPushAccountButton:(id)sender {
    [self performSegueWithIdentifier:@"AuthorizationIdentifier" sender:self];
}
- (IBAction)didPushDeleteButton:(id)sender {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if (YES == [[segue identifier] isEqualToString:@"AuthorizationIdentifier"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        MBAuthorizationViewController *authorizationController = (MBAuthorizationViewController *)navigationController.topViewController;
        authorizationController.delegate = self;
        MBTwitterAccesser *newAccesser = [[MBTwitterAccesser alloc] init];
        authorizationController.twitterAccesser = newAccesser;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[MBAccountManager sharedInstance] selectAccountAtIndexPath:indexPath];
}

#pragma mark - 
#pragma mark AuthorizationViewController Delegate
- (void)dismissAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

@end

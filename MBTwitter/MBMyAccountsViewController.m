//
//  MBMyAccountsViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMyAccountsViewController.h"
#import "MBAccountManager.h"
#import "MBTwitterAccesser.h"

@interface MBMyAccountsViewController ()

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
    [self.twitterAccessor isAuthorized];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

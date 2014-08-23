//
//  MBFollowRequestViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBFollowRequestViewController.h"

#import "MBFollowRequestTableViewCell.h"
static NSString *followRequestCellIdentifier = @"FollowRequestCellIdentifier";

@interface MBFollowRequestViewController ()

@end

@implementation MBFollowRequestViewController
#pragma mark - Initialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View
- (void)configureView
{
    UINib *requestNib = [UINib nibWithNibName:@"MBFollowRequestTableViewCell" bundle:nil];
    [self.tableView registerNib:requestNib forCellReuseIdentifier:followRequestCellIdentifier];
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

#pragma mark - Instance Methods
- (void)backUsersAtCursor:(long long)cursor
{
    [self.aoAPICenter getUserIDsForPendingRequestToMeWithCursor:cursor];
}

#pragma mark - Delegate
#pragma mark TableView
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUserIDs:(NSArray *)userIDs next:(NSNumber *)next previous:(NSNumber *)previous
{
    self.nextCursor = next;
    self.previousCursor = previous;
}

@end

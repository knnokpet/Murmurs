//
//  MBFavoritesViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBFavoritesViewController.h"

@interface MBFavoritesViewController ()

@end

@implementation MBFavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setUser:(MBUser *)user
{
    _user = user;
}

#pragma mark -
#pragma mark View
- (void)configureNavigationItem
{
    // nothing
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Favorite", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)goBackTimelineMaxID:(unsigned long long)max
{
    if (self.user) {
        [self.aoAPICenter getBackFavoritesForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName maxID:max];
    }
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    [self.aoAPICenter getForwardFavoritesForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName sinceID:since];
}

- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max
{
    [self.aoAPICenter getFavoritesForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName sinceID:since maxID:max];
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

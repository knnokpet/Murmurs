//
//  MBUserTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUserTimelineViewController.h"

@interface MBUserTimelineViewController ()

@end

@implementation MBUserTimelineViewController
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
#pragma mark Setter & Getter
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBackTimelineMaxID:(unsigned long long)max
{
    if (self.user) {
        [self.aoAPICenter getBackUserTimelineUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName maxID:max];
    }
}

#pragma mark Action
- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max
{
    [self.aoAPICenter getUserTimelineUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName sinceID:since maxID:max];
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    [self.aoAPICenter getForwardUserTimelineUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName sinceID:since];
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

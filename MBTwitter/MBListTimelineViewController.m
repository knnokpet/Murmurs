//
//  MBListTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListTimelineViewController.h"

#import "MBListManager.h"
#import "MBList.h"

@interface MBListTimelineViewController ()

@end

@implementation MBListTimelineViewController
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
- (void)setList:(MBList *)list
{
    _list = list;
}

#pragma mark -
#pragma mark View
- (void)configureTimelineManager
{
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    if (currentAccount) {
        if ([self.list.user.userIDStr isEqualToString:currentAccount.userID]) {
            self.timelineManager = [currentAccount.listManager timelineManagerForListID:self.list.listID];
            self.dataSource = self.timelineManager.tweets;
            return;
        }
    }
    
    self.timelineManager = [[MBTimeLineManager alloc] init];
    self.dataSource = self.timelineManager.tweets;
}

- (void)configureNavigationItem
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    [self.aoAPICenter getBackListTimeline:[self.list.listID unsignedLongLongValue] slug:self.list.slug ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue] max:max];
}

#pragma mark Action
- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max
{
    [self.aoAPICenter getListTimeline:[self.list.listID unsignedLongLongValue] slug:self.list.slug ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue] since:since max:max];
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    [self.aoAPICenter getForwardListTimeline:[self.list.listID unsignedIntegerValue] slug:self.list.slug ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue] since:since];
}


#pragma mark -
#pragma mark TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets
{
    [self updateTableViewDataSource:tweets];
}

@end

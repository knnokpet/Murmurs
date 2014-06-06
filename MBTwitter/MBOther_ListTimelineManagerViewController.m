//
//  MBOther_ListTimelineManagerViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBOther_ListTimelineManagerViewController.h"

@interface MBOther_ListTimelineManagerViewController ()

@end

@implementation MBOther_ListTimelineManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureNavigationItem
{
    UIBarButtonItem *rightBarButtonitem;
    if (self.list.isFollowing) {
        rightBarButtonitem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UnSubscrive", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushUnSubscriveButton)];
    } else {
        rightBarButtonitem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Subscrive", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushSubscriveButton)];
    }
    self.navigationItem.rightBarButtonItem = rightBarButtonitem;
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

- (void)didPushSubscriveButton
{
    [self.aoAPICenter postSubscriveList:[self.list.listID unsignedLongLongValue] slug:self.list.slug ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue]];
    
    UIBarButtonItem *unSubscriveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UnSubscrive", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushUnSubscriveButton)];
    [self.navigationItem setRightBarButtonItem:unSubscriveButton animated:YES];
}

- (void)didPushUnSubscriveButton
{
    [self.aoAPICenter postDestroySubscrivedList:[self.list.listID unsignedLongLongValue] slug:self.list.slug ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue]];
    
    UIBarButtonItem *subscriveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Subscrive", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushSubscriveButton)];
    [self.navigationItem setRightBarButtonItem:subscriveButton animated:YES];
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

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedLists:(NSArray *)lists
{
    if (0 < [lists count]) {
        MBList *subscrivedList = [lists firstObject];
        if (!subscrivedList) {
            return;
        }
        if (self.list.isFollowing) {
            UIBarButtonItem *subscriveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Subscrive", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushSubscriveButton)];
            [self.navigationItem setRightBarButtonItem:subscriveButton animated:YES];
            
            if ([_delegate respondsToSelector:@selector(unsubscriveOtherListTimelineManagerViewController:)]) {
                [_delegate unsubscriveOtherListTimelineManagerViewController:self];
            }
        } else {
            [self setList:subscrivedList];
            UIBarButtonItem *unSubscriveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UnSubscrive", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushUnSubscriveButton)];
            [self.navigationItem setRightBarButtonItem:unSubscriveButton animated:YES];
            
            if ([_delegate respondsToSelector:@selector(subscriveOtherListTimelineManagerViewController:list:)]) {
                [_delegate subscriveOtherListTimelineManagerViewController:self list:subscrivedList];
            }
        }
        
    } else {
    }
}

@end

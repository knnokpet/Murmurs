//
//  MBListTimelineManagementViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListTimelineManagementViewController.h"


@interface MBListTimelineManagementViewController ()

@end

@implementation MBListTimelineManagementViewController
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
- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
}

- (void)configureView
{
    [self configureNavigationItem];
}

- (void)configureNavigationItem
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self commonConfigureModel];
    [self configureView];
    
    CGFloat containerHeight = self.containerView.frame.size.height;
    
    MBListTimelineViewController *listTimelineViewController = [[MBListTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
    [listTimelineViewController setList:self.list];
    [self addChildViewController:listTimelineViewController];
    listTimelineViewController.view.frame = self.view.bounds;
    self.currentController = listTimelineViewController;
    // insets
    UIEdgeInsets contentInsets = listTimelineViewController.tableView.contentInset;
    contentInsets.top = contentInsets.top + containerHeight;
    listTimelineViewController.tableView.contentInset = contentInsets;
    UIEdgeInsets indicatorInsets = listTimelineViewController.tableView.scrollIndicatorInsets;
    indicatorInsets.top = indicatorInsets.top + containerHeight;
    listTimelineViewController.tableView.scrollIndicatorInsets = indicatorInsets;
    [self.view addSubview:listTimelineViewController.view];
    self.listTimelineViewController = listTimelineViewController;
    [self.listTimelineViewController didMoveToParentViewController:self];
    
    MBListMembersViewController *listMembersViewController = [[MBListMembersViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
    [listMembersViewController setList:self.list];
    [self addChildViewController:listMembersViewController];
    listMembersViewController.view.frame = self.view.bounds;
    // insets
    CGFloat navigationStatusBarHeight = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    UIEdgeInsets contInsets = listMembersViewController.tableView.contentInset;
    contInsets.top = containerHeight + navigationStatusBarHeight;
    contInsets.bottom = tabBarHeight;// + navigationStatusBarHeight;
    listMembersViewController.tableView.contentInset = contInsets;
    UIEdgeInsets scrollInsets = listMembersViewController.tableView.scrollIndicatorInsets;
    scrollInsets.top = containerHeight + navigationStatusBarHeight;
    scrollInsets.bottom = tabBarHeight ;//+ navigationStatusBarHeight;
    listMembersViewController.tableView.scrollIndicatorInsets = scrollInsets;
    self.listMembersViewController = listMembersViewController;
    
    
    _viewControllers = [NSArray arrayWithObjects:listTimelineViewController, listMembersViewController, nil];
    
    
    [self.segmentedController setTitle:NSLocalizedString(@"Tweet", nil) forSegmentAtIndex:0];
    [self.segmentedController setTitle:NSLocalizedString(@"Member", nil) forSegmentAtIndex:1];
    
    [self.view bringSubviewToFront:self.containerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
#pragma mark Action
- (IBAction)didChangeSegmentedControl:(id)sender {
    NSInteger selectedIndex = self.segmentedController.selectedSegmentIndex;
    UIViewController *selectedViewController = [self.viewControllers objectAtIndex:selectedIndex];
    [self addChildViewController:selectedViewController];/* willMoveTo を呼んでくれる */
    selectedViewController.view.frame = self.view.bounds;
    
    // ViewController 遷移
    [self transitionFromViewController:self.currentController toViewController:selectedViewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        // 勝手に剥がされる [self.currentController.view removeFromSuperview];
        // 勝手に追加される [self.view addSubview:selectedViewController.view];
        
    }completion: ^(BOOL finished){
        // willMoveTo が呼ばれているから良いのでは？ [selectedViewController didMoveToParentViewController:self];
        [self.currentController removeFromParentViewController];
        self.currentController = selectedViewController;
    }];
    [self.view bringSubviewToFront:self.containerView];
}

@end

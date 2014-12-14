//
//  MBListTimelineManagementViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListTimelineManagementViewController.h"


@interface MBListTimelineManagementViewController ()
{
    CGFloat defaultContainerHeight;
    CGFloat defaultContainerOriginY;
    CGPoint beginScrollingPoint;
}

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
    
    defaultContainerHeight = 44.0f;
    defaultContainerOriginY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height;
    _containerView = [[MBSegmentedContainerView alloc] initWithFrame:CGRectMake(0, defaultContainerOriginY, self.view.bounds.size.width, defaultContainerHeight)];
    [self.view addSubview:self.containerView];
    
    _segmentedController = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Tweet", nil), NSLocalizedString(@"Member", nil)]];
    self.segmentedController.selectedSegmentIndex = 0;
    [self.containerView addSubview:self.segmentedController];
    CGSize segmentSize = CGSizeMake(self.containerView.bounds.size.width - 40, self.segmentedController.bounds.size.height);
    CGRect segmentRect = CGRectMake(self.containerView.center.x - segmentSize.width / 2, self.containerView.bounds.size.height / 2 - segmentSize.height / 2, segmentSize.width, segmentSize.height);
    self.segmentedController.frame = segmentRect;
    [self.segmentedController addTarget:self action:@selector(didChangeSegmentedControl) forControlEvents:UIControlEventValueChanged];
    
    [self.segmentedController setTitle:NSLocalizedString(@"Tweet", nil) forSegmentAtIndex:0];
    [self.segmentedController setTitle:NSLocalizedString(@"Member", nil) forSegmentAtIndex:1];
    [self.view bringSubviewToFront:self.containerView];
}

- (void)configureChildViewControllers
{
    
    MBListTimelineViewController *listTimelineViewController = [[MBListTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
    [listTimelineViewController setList:self.list];
    [self addChildViewController:listTimelineViewController];
    listTimelineViewController.view.frame = self.view.bounds;
    self.currentController = listTimelineViewController;/* unused */
    //listTimelineViewController.delegate = self;
    
    [self.view addSubview:listTimelineViewController.view];
    self.listTimelineViewController = listTimelineViewController;
    [self.listTimelineViewController didMoveToParentViewController:self];
    
    
    MBListMembersViewController *listMembersViewController = [[MBListMembersViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
    [listMembersViewController setList:self.list];
    [self addChildViewController:listMembersViewController];
    listMembersViewController.view.frame = self.view.bounds;
    //listMembersViewController.scrollDelegate = self;/* unused */
    
    
    self.listMembersViewController = listMembersViewController;
    
    
    _viewControllers = [NSArray arrayWithObjects:listTimelineViewController, listMembersViewController, nil];
}

- (void)constraintChildViewControllers
{
    CGFloat containerHeight = defaultContainerHeight;
    
    // insets
    UIEdgeInsets contentInsets = self.listTimelineViewController.tableView.contentInset;
    contentInsets.top = contentInsets.top + containerHeight;
    self.listTimelineViewController.tableView.contentInset = contentInsets;
    UIEdgeInsets indicatorInsets = self.listTimelineViewController.tableView.scrollIndicatorInsets;
    indicatorInsets.top = indicatorInsets.top + containerHeight;
    self.listTimelineViewController.tableView.scrollIndicatorInsets = indicatorInsets;
    
    // insets
    CGFloat navigationStatusBarHeight = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    UIEdgeInsets contInsets = self.listMembersViewController.tableView.contentInset;
    contInsets.top = containerHeight + navigationStatusBarHeight;
    contInsets.bottom = tabBarHeight;// + navigationStatusBarHeight;
    self.listMembersViewController.tableView.contentInset = contInsets;
    UIEdgeInsets scrollInsets = self.listMembersViewController.tableView.scrollIndicatorInsets;
    scrollInsets.top = containerHeight + navigationStatusBarHeight;
    scrollInsets.bottom = tabBarHeight ;//+ navigationStatusBarHeight;
    self.listMembersViewController.tableView.scrollIndicatorInsets = scrollInsets;
}

- (void)configureNavigationItem
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.list.name;
    
    [self commonConfigureModel];
    [self configureChildViewControllers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureView];
    [self constraintChildViewControllers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
#pragma mark Action
- (void)didChangeSegmentedControl {
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

#pragma mark - MBListTimelineTableViewController Delegate
- (void)listTimelineScrollViewDidScroll:(MBListTimelineViewController *)controller scrollView:(UIScrollView *)scrollView
{
    if (scrollView.decelerating) {
        [self showContainerViewWithScrollView:scrollView];
    } else if (scrollView.dragging) {
        [self changeContainerViewRectWithScrollView:scrollView];
    }
    
}

- (void)listTimelineScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginScrollingPoint = scrollView.contentOffset;
}

- (void)listTimelineScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.containerView.frame.origin.y < defaultContainerOriginY && self.containerView.frame.origin.y > defaultContainerOriginY - defaultContainerHeight) {
        CGFloat top = defaultContainerOriginY;
        if (scrollView.contentOffset.y < beginScrollingPoint.y) {
            top = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height - defaultContainerHeight;
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            CGRect containerRect = self.containerView.frame;
            containerRect.origin.y = top;
            self.containerView.frame = containerRect;
            
            [self fitTopInsets:containerRect.origin.y + containerRect.size.height WithScrollView:scrollView];
        }];
    }
}

#pragma mark 
- (void)changeContainerViewRectWithScrollView:(UIScrollView *)scrollView
{
    CGFloat originY = defaultContainerOriginY;
    CGFloat top = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height + defaultContainerHeight;
    CGFloat result = scrollView.contentOffset.y - beginScrollingPoint.y;
    if (result > defaultContainerHeight) {
        result = defaultContainerHeight;
    } else if (result < 0) {
        return;
    }
    
    CGRect containerRect = self.containerView.frame;
    containerRect.origin.y = originY - result;
    self.containerView.frame = containerRect;
    
    [self fitTopInsets:top - result WithScrollView:scrollView];
}

- (void)showContainerViewWithScrollView:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > beginScrollingPoint.y) {
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect containerRect = self.containerView.frame;
        containerRect.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height;
        self.containerView.frame = containerRect;
        
        [self fitTopInsets:containerRect.origin.y + containerRect.size.height WithScrollView:scrollView];
    }];
}

- (void)fitTopInsets:(CGFloat)top WithScrollView:(UIScrollView *)scrollView
{
    UIEdgeInsets contentInsets = scrollView.contentInset;
    contentInsets.top = top;
    scrollView.contentInset = contentInsets;
    UIEdgeInsets indicatorInsets = scrollView.scrollIndicatorInsets;
    contentInsets.top = top;
    scrollView.scrollIndicatorInsets = indicatorInsets;
}

#pragma mark MBListMembersViewControllerScrollView Delegate
- (void)listMembersScrollViewDidScroll:(MBListMembersViewController *)controller scrollView:(UIScrollView *)scrollView
{
    if (scrollView.decelerating) {
        [self showContainerViewWithScrollView:scrollView];
    } else if (scrollView.dragging) {
        [self changeContainerViewRectWithScrollView:scrollView];
    }
}

- (void)listMembersScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginScrollingPoint = scrollView.contentOffset;
}

- (void)listMembersScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.containerView.frame.origin.y < defaultContainerOriginY && self.containerView.frame.origin.y > defaultContainerOriginY - defaultContainerHeight) {
        CGFloat top = defaultContainerOriginY;
        if (scrollView.contentOffset.y < beginScrollingPoint.y) {
            top = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height - defaultContainerHeight;
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            CGRect containerRect = self.containerView.frame;
            containerRect.origin.y = top;
            self.containerView.frame = containerRect;
            
            [self fitTopInsets:containerRect.origin.y + containerRect.size.height WithScrollView:scrollView];
        }];
    }
}

@end

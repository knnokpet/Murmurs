//
//  MBSearchViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSearchViewController.h"

@interface MBSearchViewController ()

@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) UIBarButtonItem *tweetButton;

@end

@implementation MBSearchViewController

#pragma mark - Initialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -View
- (void)configureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    self.aoAPICenter.delegate = self;
}

- (void)configureView
{
    // searchBar
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    self.searchBar.barStyle = UISearchBarStyleDefault;
    NSString *searchBarPlaceHolder = NSLocalizedString(@"Search for Tweet or User", nil);
    [self.searchBar setPlaceholder:searchBarPlaceHolder];
    self.searchBar.delegate = self;
    [self.navigationItem setTitleView:self.searchBar];
    
    // segmentedControlContainerView
    _segmentedContainerView = [[MBSegmentedContainerView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 45)];
    [self.view addSubview:self.segmentedContainerView];
    [self updateContainerView];
    
    // segmentedControl
    /* アイコンもアリだ */
    NSString *tweetStr = NSLocalizedString(@"Tweet", nil);
    NSString *userStr = NSLocalizedString(@"User", nil);
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[tweetStr, userStr]];
    
    [self.segmentedControl addTarget:self action:@selector(didChangeSegmentedControlValue) forControlEvents:UIControlEventValueChanged];
    [self.segmentedContainerView addSubview:self.segmentedControl];
    CGRect segmentedRect = self.segmentedControl.frame;
    segmentedRect.size.width = 280;
    segmentedRect.origin.x = self.segmentedControl.superview.bounds.size.width / 2 - segmentedRect.size.width / 2;
    segmentedRect.origin.y = self.segmentedControl.superview.bounds.size.height / 2 - segmentedRect.size.height / 2;
    self.segmentedControl.frame = segmentedRect;
    
    
    [self configureNabigationItem];
}

- (void)configureNabigationItem
{
    _tweetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(didPushTweetButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureModel];
    [self configureView];
    
    CGFloat containerOriginY = self.segmentedContainerView.frame.origin.y;
    CGFloat containeHeight = self.segmentedContainerView.frame.size.height;
    //CGFloat navigationStatusBarHeight = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    _tweetViewController = [[MBSearchedTweetViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
    self.tweetViewController.delegate = self;
    self.tweetViewController.view.frame = self.view.bounds;/* bounds であることが重要 */
    [self addChildViewController:self.tweetViewController];
    self.currentController = self.tweetViewController;
    // insets
    UIEdgeInsets contentInsets = self.tweetViewController.tableView.contentInset;
    contentInsets.top = containeHeight + containerOriginY;
    contentInsets.bottom = tabBarHeight;
    self.tweetViewController.tableView.contentInset = contentInsets;
    UIEdgeInsets indicatorInsets = self.tweetViewController.tableView.scrollIndicatorInsets;
    indicatorInsets.top = containeHeight+ containerOriginY;
    indicatorInsets.bottom = tabBarHeight;
    self.tweetViewController.tableView.scrollIndicatorInsets = indicatorInsets;
    
    _usersViewController = [[MBSearchedUsersViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
    self.usersViewController.delegate = self;
    self.usersViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.usersViewController];
    // inset
    
    UIEdgeInsets contInset = self.usersViewController.tableView.contentInset;
    contInset.top = containeHeight; //+ containerOriginY;
    //contInset.bottom = tabBarHeight;
    self.usersViewController.tableView.contentInset = contInset;
    UIEdgeInsets scrollInsets = self.usersViewController.tableView.scrollIndicatorInsets;
    scrollInsets.top = containeHeight; //+ containerOriginY;
    //scrollInsets.bottom = tabBarHeight;NSLog(@"tabbarhei = %f", tabBarHeight);
    self.usersViewController.tableView.scrollIndicatorInsets = scrollInsets;
    
    
    _viewControllers = @[self.tweetViewController, self.usersViewController];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [self receiveChengedAccountNotification];
}

- (void)receiveChengedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self configureModel];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods
- (void)updateContainerView
{
    if (self.tweetViewController.view.superview || self.usersViewController.view.superview) {
        [self.view addSubview:self.segmentedContainerView];
    } else {
        [self.segmentedContainerView removeFromSuperview];
    }
}

#pragma mark NavigationItem

- (void)changeNavigationItemToTweetButtonWithAnimated:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:self.tweetButton animated:animated];
}

- (void)changeNavigationItemtoNonWithAnimated:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:nil animated:animated];
}

#pragma mark View Action
- (void)didPushTweetButton
{
    
}

- (void)didChangeSegmentedControlValue
{
    NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
    UIViewController *nextViewController = [self.viewControllers objectAtIndex:selectedIndex];
    [self addChildViewController:nextViewController];
    nextViewController.view.frame = self.view.bounds;
    
    [self transitionFromViewController:self.currentController toViewController:nextViewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        
    }completion:^(BOOL finished) {
        [self.currentController removeFromParentViewController];
        self.currentController = nextViewController;
    }];
    [self.view bringSubviewToFront:self.segmentedContainerView];
}

#pragma mark Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Delegate
#pragma mark AouthAPICenter Delegate

#pragma mark UISearchBar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self changeNavigationItemToTweetButtonWithAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.navigationItem setRightBarButtonItem:self.tweetButton animated:YES];
    [self changeNavigationItemToTweetButtonWithAnimated:YES];
    
    self.tweetViewController.query = searchBar.text;
    self.usersViewController.query = searchBar.text;
    
    [self.view addSubview:self.usersViewController.view];
    [self.view addSubview:self.tweetViewController.view];
    NSInteger segmentIndex = self.segmentedControl.selectedSegmentIndex;
    if (segmentIndex == 0) {
        [self.view bringSubviewToFront:self.tweetViewController.view];
    } else if (segmentIndex == 1) {
        [self.view bringSubviewToFront:self.usersViewController.view];
    }
    
    [self updateContainerView];
    //[self.view bringSubviewToFront:self.segmentedContainerView];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self changeNavigationItemtoNonWithAnimated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

#pragma mark SearchedTweetsViewController Delegate
- (void)scrollViewInSearchedTweetsViewControllerBeginDragging:(MBSearchedTweetViewController *)controller
{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self changeNavigationItemToTweetButtonWithAnimated:YES];
}

#pragma mark SearchedUsersViewCOntroller Delegate
- (void)scrollViewInSearchedUsersViewControllerBeginDragging:(MBSearchedUsersViewController *)controller
{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self changeNavigationItemToTweetButtonWithAnimated:YES];
}

@end

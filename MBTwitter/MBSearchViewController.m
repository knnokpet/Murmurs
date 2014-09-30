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
@property (nonatomic) UIView *viewForHiding;

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

#pragma mark Setter & Getter
- (void)setSearchingTweetQuery:(NSString *)searchingTweetQuery
{
    _searchingTweetQuery = searchingTweetQuery;
}

- (void)setBecameFirstResponder:(BOOL)becameFirstResponder
{
    _becameFirstResponder = becameFirstResponder;
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
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 20, 44)];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchBarBackgroundImage"] forState:UIControlStateNormal];
    NSString *searchBarPlaceHolder = NSLocalizedString(@"Search Tweet or User", nil);
    [self.searchBar setPlaceholder:searchBarPlaceHolder];
    self.searchBar.delegate = self;
    [self.navigationItem setTitleView:self.searchBar];
    
    // segmentedControlContainerView
    _segmentedContainerView = [[MBSegmentedContainerView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 45)];
    
    // segmentedControl
    /* アイコンもアリだ */
    NSString *tweetStr = NSLocalizedString(@"Tweet", nil);
    NSString *userStr = NSLocalizedString(@"User", nil);
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[tweetStr, userStr]];
    
    [self.segmentedControl addTarget:self action:@selector(didChangeSegmentedControlValue) forControlEvents:UIControlEventValueChanged];
    [self.segmentedContainerView addSubview:self.segmentedControl];
    CGRect segmentedRect = self.segmentedControl.frame;
    segmentedRect.size.width = self.view.bounds.size.width - 40;
    segmentedRect.origin.x = self.segmentedControl.superview.bounds.size.width / 2 - segmentedRect.size.width / 2;
    segmentedRect.origin.y = self.segmentedControl.superview.bounds.size.height / 2 - segmentedRect.size.height / 2;
    self.segmentedControl.frame = segmentedRect;
    
    self.viewForHiding = [[UIView alloc] initWithFrame:self.view.bounds];
    self.viewForHiding.backgroundColor = [UIColor whiteColor];
    
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
    
    _tweetViewController = [[MBSearchedTweetViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
    self.tweetViewController.delegate = self;
    self.tweetViewController.view.frame = self.view.bounds;/* bounds であることが重要 */
    [self addChildViewController:self.tweetViewController];
    self.currentController = self.tweetViewController;
    
    _usersViewController = [[MBSearchedUsersViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
    self.usersViewController.delegate = self;
    self.usersViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.usersViewController];
    [self.view addSubview:self.usersViewController.view];
    
    [self.view addSubview:self.tweetViewController.view];
    
    _viewControllers = @[self.tweetViewController, self.usersViewController];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [self.view addSubview:self.viewForHiding];
    
    [self searchTweet];
    
    [self receiveChengedAccountNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showKeyboard];
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
        [self applySegmentedInset];
    } else {
        [self.segmentedContainerView removeFromSuperview];
    }
}

- (void)applySegmentedInset
{
    CGFloat containerOriginY = self.segmentedContainerView.frame.origin.y;
    CGFloat containeHeight = self.segmentedContainerView.bounds.size.height;
    CGFloat bottomHeight = 0;
    if (self.tabBarController) {
        bottomHeight = self.tabBarController.tabBar.frame.size.height;
    }
    
    // insets
    UIEdgeInsets contentInsets = self.tweetViewController.tableView.contentInset;
    contentInsets.top = containeHeight + containerOriginY;
    contentInsets.bottom = bottomHeight;
    self.tweetViewController.tableView.contentInset = contentInsets;
    UIEdgeInsets indicatorInsets = self.tweetViewController.tableView.scrollIndicatorInsets;
    indicatorInsets.top = containeHeight + containerOriginY;
    indicatorInsets.bottom = bottomHeight;
    self.tweetViewController.tableView.scrollIndicatorInsets = indicatorInsets;
    
    UIEdgeInsets contInset = self.usersViewController.tableView.contentInset;
    contInset.top = containeHeight + self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height;
    self.usersViewController.tableView.contentInset = contInset;
    UIEdgeInsets scrollInsets = self.usersViewController.tableView.scrollIndicatorInsets;
    scrollInsets.top = containeHeight + self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height;
    self.usersViewController.tableView.scrollIndicatorInsets = scrollInsets;
}

- (void)applyNonSegmentedInset
{
    CGFloat navigationbarOriginY = self.navigationController.navigationBar.frame.origin.y;
    CGFloat navigationbarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat bottomHeight = 0;
    if (self.tabBarController) {
        bottomHeight = self.tabBarController.tabBar.frame.size.height;
    }
    
    // insets
    UIEdgeInsets contentInsets = self.tweetViewController.tableView.contentInset;
    contentInsets.top = navigationbarHeight + navigationbarOriginY;
    contentInsets.bottom = bottomHeight;
    self.tweetViewController.tableView.contentInset = contentInsets;
    UIEdgeInsets indicatorInsets = self.tweetViewController.tableView.scrollIndicatorInsets;
    indicatorInsets.top = navigationbarHeight + navigationbarOriginY;
    indicatorInsets.bottom = bottomHeight;
    self.tweetViewController.tableView.scrollIndicatorInsets = indicatorInsets;
}

- (void)searchTweet
{
    if (!self.searchingTweetQuery || self.searchingTweetQuery.length == 0) {
        return;
    }
    self.searchBar.text = self.searchingTweetQuery;
    [self.searchBar setShowsCancelButton:NO animated:NO];
    [self.searchBar resignFirstResponder];
    [self changeNavigationItemToTweetButtonWithAnimated:NO];
    
    self.tweetViewController.query = self.searchBar.text;
    [self addChildViewController:self.tweetViewController];
    [self.view addSubview:self.tweetViewController.view];
    [self applyNonSegmentedInset];
    
    self.searchingTweetQuery = nil;
}

- (void)showKeyboard
{
    if (!self.becameFirstResponder) {
        return;
    }
    
    [self.searchBar becomeFirstResponder];
    self.becameFirstResponder = NO;
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

#pragma mark Keyboard
- (void)keyboardWillAppear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.viewForHiding.backgroundColor = [UIColor grayColor];
    }completion:nil];
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.viewForHiding.backgroundColor = [UIColor whiteColor];
    }completion:nil];
}

#pragma mark View Action
- (void)didPushTweetButton
{
    MBPostTweetViewController *postViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didChangeSegmentedControlValue
{
    NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
    UIViewController *nextViewController = [self.viewControllers objectAtIndex:selectedIndex];
    [self addChildViewController:nextViewController];
    nextViewController.view.frame = self.view.bounds;
    
    [self transitionFromViewController:self.currentController toViewController:nextViewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        [self applySegmentedInset];
        
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
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets
{
    MBTweet *tweet = [tweets firstObject];
    if (tweet) {
        [self.tweetViewController refreshAction];
    }
}

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
    
    [self.viewForHiding removeFromSuperview];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self changeNavigationItemtoNonWithAnimated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        if (self.tweetViewController.view.superview) {
            [self.tweetViewController.view removeFromSuperview];
        }
        if (self.usersViewController.view.superview) {
            [self.usersViewController.view removeFromSuperview];
        }
        [self updateContainerView];
        [self.view addSubview:self.viewForHiding];
    }
    
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

#pragma mark MBPostTweetViewController Delegate
- (void)dismissPostTweetViewController:(MBPostTweetViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:^{
        
    }];
}

- (void)sendTweetPostTweetViewController:(MBPostTweetViewController *)controller tweetText:(NSString *)tweetText replys:(NSArray *)replys place:(NSDictionary *)place media:(NSArray *)media
{
    [self.aoAPICenter postTweet:tweetText inReplyTo:replys place:place media:media];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

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
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
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
    self.searchBar.delegate = self;
    [self.navigationItem setTitleView:self.searchBar];
    
    [self configureNabigationItem];
}

- (void)configureNabigationItem
{
    _cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushCancelButton)];
    _tweetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(didPushTweetButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureModel];
    [self configureView];
    
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

#pragma mark NavigationItem
- (void)changeNavigationItemToCancelButtonWithAnimated:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:self.cancelButton animated:animated];
}

- (void)changeNavigationItemToTweetButtonWithAnimated:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:self.tweetButton animated:animated];
}

- (void)changeNavigationItemtoNonWithAnimated:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:nil animated:animated];
}

#pragma mark Button Action
- (void)didPushCancelButton
{
    [self changeNavigationItemtoNonWithAnimated:YES];
}

- (void)didPushTweetButton
{
    
}

#pragma mark - Delegate
#pragma mark AouthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
    if (tweets.count > 0) {
        ;
    }
}

#pragma mark UISearchBar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.aoAPICenter getSearchedTweetsWithQuery:searchBar.text];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[self changeNavigationItemToCancelButtonWithAnimated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}


@end

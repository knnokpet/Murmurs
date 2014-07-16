//
//  MBSearchedUsersViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSearchedUsersViewController.h"

@interface MBSearchedUsersViewController ()
{
    unsigned long page;
}

@end

@implementation MBSearchedUsersViewController
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

- (void)configureModel
{
    page = 1;
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setQuery:(NSString *)query
{
    _query = query;
    
    [self.users removeAllObjects];
    [self configureModel];
    [self.tableView reloadData];
    [self backUsersAtCursor:0];
}

#pragma mark -
#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark InstanceMethods
- (void)backUsersAtCursor:(long long)cursor
{
    /* 検索結果は page で表現されるため、強引にメソッドを page 用に変更 */
    if (self.query.length > 0) {
        [self.aoAPICenter getSearchedUsersWithQuery:self.query page:page];
    }
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

#pragma mark -
#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users
{
    if (users.count > 0) {
        page++;
        
        [self updateTableViewDataSource:users];
    } else if (users.count == 0) {
        self.enableAdding = NO;
    }
}

#pragma mark UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(scrollViewInSearchedUsersViewControllerBeginDragging:)]) {
        [_delegate scrollViewInSearchedUsersViewControllerBeginDragging:self];
    }
}

@end

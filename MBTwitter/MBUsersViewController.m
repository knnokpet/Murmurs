//
//  MBUsersViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsersViewController.h"
#import "MBDetailUserViewController.h"

@interface MBUsersViewController ()


@end

@implementation MBUsersViewController
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
- (void)configureModel
{
    
}

- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    _users = [NSMutableArray array];
    
    self.enableAdding = NO;
    self.nextCursor = [NSNumber numberWithInt:-1];
    
    [self configureModel];
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)configureNavigationItem
{
    
}

- (void)commonConfigureNavigationItem
{
    [self configureNavigationItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self commonConfigureModel];
    [self commonConfigureView];
    
    [self goBacksWithCursor:self.nextCursor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)goBacksWithCursor:(NSNumber *)cursor
{
    long long llCursor = [cursor longLongValue];

    if (0 == llCursor) {
        return;
    } else {
        self.enableAdding = NO;
        [self backUsersAtCursor:llCursor];
    }
}

- (void)backUsersAtCursor:(long long)cursor
{
    
}

#pragma mark -
#pragma mark UITableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBUser *userAtIndex = [self.users objectAtIndex:indexPath.row];
    cell.textLabel.text = userAtIndex.characterName;
}

- (NSArray *)decorateAddingArray:(NSArray *)decoratedArray
{
    //overridden
    return decoratedArray;
}

- (void)updateTableViewDataSource:(NSArray *)addingArray
{
    NSArray *decoratedArray = [self decorateAddingArray:addingArray];
    NSInteger addingCount = [decoratedArray count];
    NSLog(@"addingArray = %d", [decoratedArray count]);
    if (0 == addingCount) {
        ;
    } else {
        NSInteger base = [self.users count];
        [self decorateAddingArray:decoratedArray];
        [self.users addObjectsFromArray:decoratedArray];
        
        [self.tableView beginUpdates];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = 0; i < addingCount; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:base + i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
    self.enableAdding = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBUser *selectedUser = [self.users objectAtIndex:indexPath.row];
    MBDetailUserViewController *detailUserViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
    [detailUserViewController setUser:selectedUser];
    [self.navigationController pushViewController:detailUserViewController animated:YES];
}

#pragma mark ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float max = scrollView.contentInset.top + scrollView.contentInset.bottom + scrollView.contentSize.height - scrollView.bounds.size.height;
    float current = scrollView.contentOffset.y + self.topLayoutGuide.length;
    int intMax = max * 0.5;
    int intCurrent = current;
    if (intMax < intCurrent) {
        if (self.enableAdding) {
            [self goBacksWithCursor:self.nextCursor];
        }
    }
}

#pragma mark -
#pragma mark TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users next:(NSNumber *)next previous:(NSNumber *)previous
{
    self.nextCursor = next;
    self.previousCursor = previous;
    
    [self updateTableViewDataSource:users];
}

@end

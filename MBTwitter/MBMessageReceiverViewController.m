//
//  MBMessageReceiverViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMessageReceiverViewController.h"

#import "MBUserManager.h"
#import "MBUser.h"
#import "MBUserIDManager.h"

@interface MBMessageReceiverViewController ()

@end

@implementation MBMessageReceiverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark TableVIewDelegate Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (1 == section) {
        return 1;
    }
    
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (0 == indexPath.section) {
        [self updateCell:cell atIndexPath:indexPath];
    } else if (1 == indexPath.section) {
        [self updateScreenNameCell:cell atIndexpath:indexPath];
    }
    
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBUser *userAtIndex = [[MBUserManager sharedInstance] storedUserForKey:key];
    cell.textLabel.text = userAtIndex.characterName;
}

- (void)updateScreenNameCell:(UITableViewCell *)cell atIndexpath:(NSIndexPath *)indexPath
{
    NSString *searchString = NSLocalizedString(@"Search for ", nil);
    NSString *screenNameWithAtmark = [NSString stringWithFormat:@"%@%@", searchString, self.inputedString];
    cell.textLabel.text = screenNameWithAtmark;
    cell.textLabel.textColor = [self.navigationController.navigationBar tintColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        NSString *key = [self.dataSource objectAtIndex:indexPath.row];
        MBUser *userAtIndex = [[MBUserManager sharedInstance] storedUserForKey:key];
        
        if ([_delegate respondsToSelector:@selector(selectReceiverViewController:user:)]) {
            [_delegate selectReceiverViewController:self user:userAtIndex];
        }
    } else if (1 == indexPath.section) {
        if ([_delegate respondsToSelector:@selector(selectSearchReceiverViewController:)]) {
            [_delegate selectSearchReceiverViewController:self];
        }
    }
    
}

#pragma mark ScrollviewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(scrollReceiverViewController:)]) {
        [_delegate scrollReceiverViewController:self];
    }
}

@end

//
//  MBListMembersViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListMembersViewController.h"
#import "MBList.h"

@interface MBListMembersViewController ()

@end

@implementation MBListMembersViewController
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

- (void)configureNavigationItem
{
    
}

#pragma mark -
#pragma mark Instance Methods
- (void)backUsersAtCursor:(long long)cursor
{
    [self.aoAPICenter getMembersOfList:[self.list.listID unsignedLongLongValue] slug:self.list.slug ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue] cursor:cursor];
}

#pragma mark UITableViewController Delegate
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (YES == editing) {
        
    } else {
        
    }
    
    [self.tableView setEditing:editing animated:animated];
    [super setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete) {
        if ([_delegate respondsToSelector:@selector(removeMemberListMembersViewController:user:)]) {
            [_delegate removeMemberListMembersViewController:self user:self.users[indexPath.row]];
        }
        [self.users removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

- (NSArray *)decorateAddingArray:(NSArray *)decoratedArray
{
    NSInteger index = 0;
    NSMutableArray *addingUsers = [NSMutableArray arrayWithArray:decoratedArray];
    for (MBUser *addingUser in decoratedArray) {
        for (MBUser *reservedUser in self.reservedRemovingUsers) {
            if (NSOrderedSame == [addingUser.userID compare:reservedUser.userID]) {
                [addingUsers removeObjectAtIndex:index];
            } else {
                
            }
        }
        index++;
        
        [self.list.memberIDs setObject:addingUser.userID forKey:addingUser.userID];
    }
    return addingUsers;
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

@end

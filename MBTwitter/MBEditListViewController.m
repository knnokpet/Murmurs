//
//  MBEditListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBEditListViewController.h"

#import "MBUser.h"

#import "MBEditListUserTableViewCell.h"
static NSString *editListUserCellIdentifier = @"EditListUserCellIdentifier";
static NSString *deleteListCellIdentifier = @"DeleteListCellIdentifier";

@interface MBEditListViewController ()

@property (nonatomic) NSMutableArray *removeListMembers;
@property (nonatomic, assign) BOOL isDeleting; // APICenter のデリゲート判別用

@end

@implementation MBEditListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)commonConfigureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPushCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didPushDoneButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.removeListMembers = [NSMutableArray array];
    
    self.isDeleting = NO;
    
    UINib *userCell = [UINib nibWithNibName:@"MBEditListUserTableViewCell" bundle:nil];
    [self.tableView registerNib:userCell forCellReuseIdentifier:editListUserCellIdentifier];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter & Getter
- (void)setList:(MBList *)list
{
    _list = list;
}

#pragma mark -Instance Methods
#pragma Action
- (void)didPushCancelButton
{
    if ([_editDelegate respondsToSelector:@selector(dismissEditListViewController:)]) {
        [_editDelegate dismissEditListViewController:self];
    }
}

- (void)didPushDoneButton
{
    MBTextFieldTableViewCell *listNameCell = (MBTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    MBTextFieldTableViewCell *descriptionCell = (MBTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    MBSwitchTableViewCell *switchCell = (MBSwitchTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSString *listName = listNameCell.textField.text;
    BOOL isOK = [self checksListName:listName];
    if (NO == isOK) {
        return;
    }
    
    NSString *description = descriptionCell.textField.text;
    BOOL isON = switchCell.switchView.on;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (0 < [self.removeListMembers count]) {
            for (MBUser *user in self.removeListMembers) {
                [self.aoAPICenter postDestroyMemberOfList:[self.list.listID unsignedLongLongValue] slug:self.list.slug userID:[user.userID unsignedLongLongValue] screenName:user.screenName ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue]];
            }
        }
    });
    
    
    [self.aoAPICenter postUpdateList:[self.list.listID unsignedLongLongValue] name:listName slug:self.list.slug isPublic:isON description:description];
    
}

#pragma mark UITableview Datasource & Delegate
- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 3;
    } else if (1 == section || 2 == section) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (0 == indexPath.section) {
        if (0 == indexPath.row || 1 == indexPath.row) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:textFieldCellIdentifier];
            MBTextFieldTableViewCell *textFieldCell = (MBTextFieldTableViewCell *)cell;
            textFieldCell.textField.text = self.list.name;
        }else if (1 == indexPath.row) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:textFieldCellIdentifier];
            MBTextFieldTableViewCell *textFieldCell = (MBTextFieldTableViewCell *)cell;
            textFieldCell.textField.text = self.list.description;
        }else if (2 == indexPath.row) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
            MBSwitchTableViewCell *switcCell = (MBSwitchTableViewCell *)cell;
            [switcCell.switchView setOn:self.list.isPublic];
        }
        [self updateCell:cell atIndexpath:indexPath];
    } else if (1 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:editListUserCellIdentifier];
        cell.textLabel.text = NSLocalizedString(@"Member", nil);
    } else if (2 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:deleteListCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deleteListCellIdentifier];
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = NSLocalizedString(@"Delete List", nil);
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.section) {
        MBListMembersViewController *listMembersViewController = [[MBListMembersViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
        listMembersViewController.delegate = self;
        [listMembersViewController setList:self.list];
        listMembersViewController.reservedRemovingUsers = self.removeListMembers;
        [listMembersViewController setEditing:YES animated:NO];
        [self.navigationController pushViewController:listMembersViewController animated:YES];
    } else if (2 == indexPath.section) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete List", nil) otherButtonTitles:nil, nil];
        [actionSheet showInView:self.view];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        
        self.isDeleting = YES;
        [self.aoAPICenter postDestroyOwnList:[self.list.listID unsignedLongLongValue] slug:self.list.slug ownerScreenName:self.list.user.screenName ownerID:[self.list.user.userID unsignedLongLongValue]];
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
#pragma mark ListMembersViewController
- (void)removeMemberListMembersViewController:(MBListMembersViewController *)controller user:(MBUser *)user
{
    if (user) {
        [self.removeListMembers addObject:user];
    }
}

#pragma mark AouthAPICenter Deleate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedLists:(NSArray *)lists
{
    MBList *list = [lists firstObject];
    if (list) {
        if (YES == self.isDeleting) {
            if ([_editDelegate respondsToSelector:@selector(deleteListEditListViewController:)]) {
                [_editDelegate deleteListEditListViewController:self];
            }
        } else { // editinf
            
            if ([_editDelegate respondsToSelector:@selector(editListEditListViewController:list:)]) {
                [_editDelegate editListEditListViewController:self list:list];
            }
        }
    }
}

@end

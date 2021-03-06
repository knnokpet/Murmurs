//
//  MBSelecting_ListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSelecting_ListViewController.h"

#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"

#import "MBSelectingListTableViewCell.h"
#import "MBLabelImageHeaderView.h"

static NSString *selectingListCellIdentifier = @"SelectingListCellIdentifier";

@interface MBSelecting_ListViewController ()
{
    CGFloat headerViewHeight;
}

@property (nonatomic, assign) NSInteger listIndex;
@property (nonatomic, readonly) NSMutableDictionary *editedLists;

@end

@implementation MBSelecting_ListViewController
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
- (void)setSelectingUser:(MBUser *)selectingUser
{
    _selectingUser = selectingUser;
}

#pragma mark -
#pragma mark View
- (void)configureListManager
{
    MBAccount *currentAccount;
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount]) {
        currentAccount = [[MBAccountManager sharedInstance] currentAccount];
        self.listManager = currentAccount.listManager;
    }
}

- (void)configureNavigationitem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didPushDoneButton)];
}

- (void)configureCell
{
    UINib *selectingListCellNib = [UINib nibWithNibName:@"MBSelectingListTableViewCell" bundle:nil];
    [self.tableView registerNib:selectingListCellNib forCellReuseIdentifier:selectingListCellIdentifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Add / Remove List", nil);
    
    [self settingMyUser];
    
    self.listIndex = 0;
    _editedLists = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingMyUser
{
    MBAccount *currentAccount;
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount]) {
        currentAccount = [[MBAccountManager sharedInstance] currentAccount];
        MBUser *myUser = [[MBUserManager sharedInstance] storedUserForKey:currentAccount.userID];
        [self setUser:myUser];
        
        if (!self.user) {
            [self.aoAPICenter getUser:0 screenName:currentAccount.screenName];
        } else {
            [self backOwnerLists];
        }
    }
}

#pragma mark -
#pragma mark Instance Methods
- (void)backOwnerLists
{
    long long cursor = [self.listManager.ownerNextCursor longLongValue];
    if (0 == cursor) {
        if (self.listIndex < self.listManager.ownerShipLists.count) {
            MBList *list = [self.listManager.ownerShipLists objectAtIndex:self.listIndex];
            NSNumber *memberID = [list.memberIDs objectForKey:self.selectingUser.userID];
            if (!memberID) {
                [self.aoAPICenter getShowsMemberOfList:[list.listID longLongValue] slug:list.slug userID:[self.selectingUser.userID unsignedLongLongValue] userScreenName:self.selectingUser.screenName ownerScreenName:self.user.screenName ownerID:[self.user.userID unsignedLongLongValue]];
            }
            
        } else {
            return;
        }
        
    } else {
        [self.aoAPICenter getListsOfOwnerShipWithUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName cursor:cursor];
    }
}

- (void)backSubscriveLists
{
    // nothing to do
}

#pragma mark Button Action
- (void)didPushCancelButton
{
    if ([_delegate respondsToSelector:@selector(cancelSelectingListViewController:animated:)]) {
        [_delegate cancelSelectingListViewController:self animated:YES];
    }
}

- (void)didPushDoneButton
{
    for (NSNumber *indexNumber in [self.editedLists allKeys]) {
        NSNumber *boolNumber = [self.editedLists objectForKey:indexNumber];
        BOOL adds = [boolNumber boolValue];
        MBList *selectedList = [self.listManager.ownerShipLists objectAtIndex:[indexNumber integerValue]];
        NSNumber *memberID = [selectedList.memberIDs objectForKey:self.selectingUser.userID];
        
        if (adds) {
            if (!memberID) {
                [self.aoAPICenter postCreateMemberOfList:[selectedList.listID unsignedLongLongValue] slug:selectedList.slug userID:[self.selectingUser.userID unsignedLongLongValue] screenName:self.selectingUser.screenName ownerScreenName:self.user.screenName ownerID:[self.user.userID unsignedLongLongValue]];
                
            }
        } else {
            if (memberID) {
                [self.aoAPICenter postDestroyMemberOfList:[selectedList.listID unsignedLongLongValue] slug:selectedList.slug userID:[self.selectingUser.userID unsignedLongLongValue] screenName:self.selectingUser.screenName ownerScreenName:self.user.screenName ownerID:[self.user.userID unsignedLongLongValue]];
            }
        }
    }
    
    if ([_delegate respondsToSelector:@selector(doneSelectingListViewController:animated:)]) {
        [_delegate doneSelectingListViewController:self animated:YES];
    }
}

#pragma mark -
#pragma mark Delegate
#pragma mark TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    headerViewHeight = 28;
    return headerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:section];
    MBList *list = [listsAtSection firstObject];
    MBLabelImageHeaderView *headerView = [[MBLabelImageHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerViewHeight)];
    headerView.labelString = NSLocalizedString(@"Your List" , nil);
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:list.user.userIDStr];
    if (!avatorImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadOriginImageWithURL:list.user.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:list.user.userIDStr];
                    CGSize imageSize = CGSizeMake(headerView.imageView.frame.size.width, headerView.imageView.frame.size.height);
                    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:headerView.imageView.layer.cornerRadius];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        headerView.image = radiusImage;
                    });
                }
                
            }failedHandler:^(NSURLResponse *response, NSError *error){
                
            }];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            CGSize imageSize = CGSizeMake(headerView.imageView.frame.size.width, headerView.imageView.frame.size.height);
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:avatorImage size:imageSize radius:headerView.imageView.layer.cornerRadius];
            dispatch_async(dispatch_get_main_queue(), ^{
                headerView.image = radiusImage;
            });
        });
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBSelectingListTableViewCell *selectingCell = [self.tableView dequeueReusableCellWithIdentifier:selectingListCellIdentifier];
    [self updateCell:selectingCell atIndexPath:indexPath];
    return selectingCell;
}

- (void)updateCell:(MBSelectingListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
    MBList *listAtIndex = [listsAtSection objectAtIndex:indexPath.row];
    cell.listNameLabel.text = listAtIndex.name;
    cell.descriptionTextView.text = listAtIndex.detail;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([listAtIndex.memberIDs objectForKey:self.selectingUser.userID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL adds = NO;
    BOOL isChecked = (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) ? YES : NO;
    if (isChecked) {
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        adds = YES;
    }
    
    NSNumber *indexKeyNumber = [NSNumber numberWithInteger:indexPath.row];
    NSNumber *boolNumber = [NSNumber numberWithBool:adds];
    [self.editedLists setObject:boolNumber forKey:indexKeyNumber];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users
{
    MBUser *myUser = [users firstObject];
    if (myUser) {
        if (requestType == MBTwitterListsMembersShowRequest) {
            MBList *listAtIndex = [self.listManager.ownerShipLists objectAtIndex:self.listIndex];
            [listAtIndex.memberIDs setObject:myUser.userID forKey:myUser.userID];
            [self.tableView reloadData];
            self.listIndex++;
            [self backOwnerLists];
        } else if (requestType == MBTwitterListsMembersCreateRequest) {
            
        } else if (MBTwitterUserRequest) {
            [self setUser:myUser];
            [self backOwnerLists];
        }
    }
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center error:(NSError *)error
{
    if (error) {
        self.listIndex++;
        [self backOwnerLists];
    }
}

@end

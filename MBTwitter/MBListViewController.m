//
//  MBListViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBListViewController.h"
#import "MBListTimelineManagementViewController.h"

#import "MBListsTableViewCell.h"

static NSString *listsCellIdentifier = @"ListsCellIdentifier";

@interface MBListViewController ()


@end

@implementation MBListViewController
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
    _listManager.owner = user;
}

#pragma mark -
#pragma mark View
- (void)configureListManager
{
    _listManager = [[MBListManager alloc] init];
    _listManager.owner = self.user;
}

- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    [self configureListManager];
}

- (void)commonConfigureView
{
    [self configureNavigationitem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self configureCell];
    
    /* remove nonContent's separator */
    UIView *view = [[UIView alloc] init];
    view.backgroundColor  = [UIColor clearColor];
    [self.tableView setTableHeaderView:view];
    [self.tableView setTableFooterView:view];
    
    if (self.listManager.ownerShipLists.count == 0 && self.listManager.subscriptionLists.count == 0) {
        _loadingView = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.loadingView aboveSubview:self.tableView];
    } else {
        [self removeLoadingView];
    }
    
    
    self.enableAdding = NO;
}

- (void)configureCell
{
    UINib *listsNib = [UINib nibWithNibName:@"MBListsTableViewCell" bundle:nil];
    [self.tableView registerNib:listsNib forCellReuseIdentifier:listsCellIdentifier];
}

- (void)configureNavigationitem
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"List", nil);
    
    [self commonConfigureModel];
    [self commonConfigureView];
    
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
- (void)goBacksLists
{
    [self backOwnerLists];
    [self backSubscriveLists];
    
}

- (void)backOwnerLists
{
    long long cursor = [self.listManager.ownerNextCursor longLongValue];
    if (0 == cursor) {
        return;
    } else {
        [self.aoAPICenter getListsOfOwnerShipWithUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName cursor:cursor];
    }
}

- (void)backSubscriveLists
{
    long long cursor = [self.listManager.subscriveNextCursor longLongValue];
    if (0 == cursor) {
        return;
    } else {
        [self.aoAPICenter getListsOfSubscriptionWithUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName cursor:cursor];
    }
}

- (void)removeLoadingView
{
    if (self.loadingView.superview) {
        [UIView animateWithDuration:1.0f animations:^{
            [self.loadingView setHidden:YES];
        }completion:^(BOOL finished){
            [self.loadingView removeFromSuperview];
            _loadingView = nil;
        }];
    }
}

#pragma mark Action
- (void)didPushRefreshButton
{
    
}

- (void)didPushAddListButton
{
    
}


#pragma mark -
#pragma mark UITableView Datasource & Delegate
- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 0;
    if (0 < self.listManager.ownerShipLists.count) {
        sectionCount ++;
    }
    if (0 < self.listManager.subscriptionLists.count) {
        sectionCount ++;
    }
    NSLog(@"sect count %d", sectionCount);
    return sectionCount;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *listsAtIndex = [self.listManager.lists objectAtIndex:section];
    NSLog(@"count %d", listsAtIndex.count);
    return [listsAtIndex count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    NSString *headername;
    if (NSOrderedSame == [currentAccount.userID compare:self.user.userIDStr]) {
        if (0 == section) {
            headername = NSLocalizedString(@"Your List" , nil);
        } else {
            headername = NSLocalizedString(@"Subscriving List", nil);
        }
        
    } else {
        if (0 == section) {
            NSString *ownersList = NSLocalizedString(@"%@'s List", nil);
            headername = [NSString stringWithFormat:ownersList, self.user.characterName];
        } else {
            NSString *subscrivingString = NSLocalizedString(@"%@'s Subscriving List", nil);
            headername = [NSString stringWithFormat:subscrivingString, self.user.characterName];
        }
    }
    
    if (0 == [(NSArray *)[self.listManager.lists objectAtIndex:section] count]) {
        headername = nil;
    }
    
    return headername;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat verticalMargin = 8.0f;
    CGFloat verticalUnderMargin = 0.0f;
    CGFloat verticalTextViewMargin = 44.0f;
    CGFloat horizontalLeftMargin = 64.0f;
    CGFloat horizontalRightMargin = 8.0f;
    CGFloat defaultHeight = 36.0f + verticalMargin * 2;
    
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
    MBList *listAtIndex = [listsAtSection objectAtIndex:indexPath.row];
    UITextView *sizingTextView = [[UITextView alloc] init];
    sizingTextView.font = [UIFont systemFontOfSize:14.0f];
    sizingTextView.textColor = [UIColor darkGrayColor];
    sizingTextView.text = listAtIndex.detail;
    CGSize fitSizt = [sizingTextView sizeThatFits:CGSizeMake(tableView.frame.size.width - (horizontalLeftMargin + horizontalRightMargin), CGFLOAT_MAX)];
    
    CGFloat heightWithTextView = fitSizt.height + verticalTextViewMargin + verticalUnderMargin;
    if (listAtIndex.detail.length == 0) {
        heightWithTextView = 0.0f;
    }
        
    return MAX(defaultHeight, heightWithTextView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBListsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:listsCellIdentifier];
    
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(MBListsTableViewCell
                    *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listsAtSection = [self.listManager.lists objectAtIndex:indexPath.section];
    MBList *listAtIndex = [listsAtSection objectAtIndex:indexPath.row];
    MBUser *userAtList = listAtIndex.user;
    
    cell.listNameLabel.text = listAtIndex.name;
    cell.screenNameLabel.text = [NSString stringWithFormat:@"@%@", userAtList.screenName];
    cell.descriptionTextView.text = listAtIndex.detail;
    cell.isPublic = listAtIndex.isPublic;
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:userAtList.userIDStr];
    if (!avatorImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadOriginImageWithURL:userAtList.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:userAtList.userIDStr];
                    CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:cell.avatorImageView.layer.cornerRadius];
                    [[MBImageCacher sharedInstance] storeTimelineImage:radiusImage forUserID:userAtList.userIDStr];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.avatorImageView.image = radiusImage;
                    });
                }
                
            }failedHandler:^(NSURLResponse *response, NSError *error){
                
            }];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:avatorImage size:imageSize radius:cell.avatorImageView.layer.cornerRadius];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatorImageView.image = radiusImage;
            });
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)updateTableViewDataSource:(NSArray *)addingData
{
    
    if (0 == [addingData count]) {
        ;
    } else {
        [self.listManager addLists:addingData];
        [self.tableView reloadData];
    }
    self.enableAdding = YES;
    
    // ラウンチ時に表示されている UIActivityView を remove
    [self removeLoadingView];
    
}

#pragma mark AOuth_APICenter Delegate

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedLists:(NSArray *)lists next:(NSNumber *)next previous:(NSNumber *)previous
{
    if (!lists || !next || !previous) {
        [self removeLoadingView];
        return;
    }
    
    
    MBList *addingList = [lists firstObject];
    if (!addingList) {
        [self removeLoadingView];
        return ;
    }
    MBUser *ownerOfList = addingList.user;
    if (!ownerOfList) {
        [self removeLoadingView];
        return;
    }
    
    [self updateTableViewDataSource:lists];
    
    if (NSOrderedSame == [self.user.userID compare:ownerOfList.userID]) {
        self.listManager.ownerNextCursor = next;
        if (next != 0) {
            [self backOwnerLists];
        }
    } else {
        self.listManager.subscriveNextCursor = next;
        if (next != 0) {
            [self backSubscriveLists];
        }
    }
    
}

@end

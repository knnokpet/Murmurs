//
//  MBSeparatedDirectMessageUserViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSeparatedDirectMessageUserViewController.h"
#import "MBDetailUserViewController.h"


#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBUserManager.h"
#import "MBDirectMessageManager.h"
#import "MBDirectMessage.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBUser.h"
#import "MBImageApplyer.h"
#import "NSString+TimeMargin.h"
#import "MBTweetTextComposer.h"

#import "MBUserIDManager.h"

#import "MBLoadingView.h"
#import "MBNavigationControllerTitleView.h"
#import "MBSeparatedDirectMessageUserTableViewCell.h"

@interface MBSeparatedDirectMessageUserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) MBUserIDManager *followerIDManager;
@property (nonatomic) NSArray *dataSource;

@property (nonatomic, readonly) MBLoadingView *loadingView;

@end

@implementation MBSeparatedDirectMessageUserViewController

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
#pragma mark View
- (void)configureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    self.followerIDManager = [[[MBAccountManager sharedInstance] currentAccount] followerIDManager];
    
    self.aoAPICenter.delegate = self;
    self.dataSource = [[MBDirectMessageManager sharedInstance] separatedMessages];
    
    [self fetchFollowerIDs];
}

- (void)configureView
{
    [self configureNavigationItem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    /* remove nonContent's separator */
    UIView *view = [[UIView alloc] init];
    view.backgroundColor  = [UIColor clearColor];
    [self.tableView setTableHeaderView:view];
    [self.tableView setTableFooterView:view];
    
    // refreshControl
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchCurrentMessage) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    _loadingView = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.loadingView aboveSubview:self.tableView];
}

- (void)configureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushLeftButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPushRightButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateNavigationTitleView];
    
    [self configureModel];
    [self configureView];
    // Do any additional setup after loading the view.
    UINib *separatedDMUserCell = [UINib nibWithNibName:@"SeparatedDirectMessageTableViewCell" bundle:nil];
    [self.tableView registerNib:separatedDMUserCell forCellReuseIdentifier:@"SeparatedDMUserCellIdentifier"];
    
    
    [self loadMessages];
    [self receiveChangedAccountNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
    
    for (MBSeparatedDirectMessageUserTableViewCell *cell in [self.tableView visibleCells]) {
        
        if (cell.avatorImageView.isSelected) {
            [cell.avatorImageView setIsSelected:NO withAnimated:YES];
        }
        
        NSIndexPath *updatingIndexPath = [self.tableView indexPathForCell:cell];
        [self updateCell:cell AtIndexPath:updatingIndexPath];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Instance Mthods
#pragma mark Notificaftion
- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSLog(@"user change account to = %@", [[MBAccountManager sharedInstance] currentAccount].screenName);
        [self updateNavigationTitleView];
        [self configureModel];
        [self.tableView reloadData];
        [self fetchCurrentMessage];
    }];
}

#pragma mark 
- (void)updateNavigationTitleView
{
    MBNavigationControllerTitleView *titleView = [[MBNavigationControllerTitleView alloc] initWithFrame:CGRectZero];
    [titleView setTitle:NSLocalizedString(@"Message", nil)];
    [titleView sizeToFit];
    [self.navigationItem setTitleView:titleView];
}

- (void)removeLoadingView
{
    if (self.loadingView.superview) {
        [UIView animateWithDuration:0.3f animations:^{
            self.loadingView.alpha  = 0.0f;
        }completion:^(BOOL finished){
            [self.loadingView removeFromSuperview];
            _loadingView = nil;
        }];
    }
}

- (void)loadMessages
{
    if ([[MBAccountManager sharedInstance] isSelectedAccount]) {
        [self.aoAPICenter getDeliveredDirectMessagesSinceID:0 maxID:0];
        [self.aoAPICenter getSentDirectMessagesSinceID:0 maxID:0];
    }
}

- (void)fetchCurrentMessage
{
    if ([[MBAccountManager sharedInstance] isSelectedAccount]) {
        
        MBDirectMessageManager *messageManager = [MBDirectMessageManager sharedInstance];
        MBDirectMessage *sent = [messageManager currentSentMessage];
        MBDirectMessage *deliverd = [messageManager currentDeliverdMessage];
        
        NSLog(@"sent deli  %@ %@", sent.tweetText, deliverd.tweetText);
        
        [self.aoAPICenter getDeliveredDirectMessagesSinceID:[deliverd.tweetID unsignedLongLongValue] maxID:0];
        [self.aoAPICenter getSentDirectMessagesSinceID:[sent.tweetID unsignedLongLongValue] maxID:0];
    }
}

- (void)fetchFollowerIDs
{
    if (self.followerIDManager.cursor != 0) {
        [self.aoAPICenter getFollowingMeIDs:0 screenName:self.followerIDManager.screenName cursor:[self.followerIDManager.cursor longLongValue]];
    }
}

- (void)fetchUsersForStoredIds
{
    NSMutableArray *fechingIDs = [NSMutableArray arrayWithCapacity:100];
    
    NSArray *requireIds = [self.followerIDManager.requireLoadingIDs allValues];
    if (requireIds.count == 0 ) {
        return;
    }
    
    NSInteger i = 0;
    for (NSNumber *userID in requireIds) {
        if (i < 100) {
            [fechingIDs addObject:userID];
            i++;
        } else {
            break;
        }
    }
    
    [self.aoAPICenter getUsersLookupUserIDs:fechingIDs];
}

#pragma mark Action
- (void)didPushLeftButton
{
    MBMyAccountsViewController *accountViewController = [[MBMyAccountsViewController alloc] initWithNibName:@"MyAccountView" bundle:nil];
    accountViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushRightButton
{
    MBIndividualDirectMessagesViewController *messageViewController = [[MBIndividualDirectMessagesViewController alloc] init];
    messageViewController.delegate = self;
    [messageViewController setIsEditing:YES];
    [messageViewController setUserIDManager:self.followerIDManager];
    [self.navigationController pushViewController:messageViewController animated:YES];
}

#pragma mark -
#pragma mark TableView Delegate & Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f + 12.0f + 12.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SeparatedDMUserCellIdentifier";
    
    MBSeparatedDirectMessageUserTableViewCell *dmCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [self updateCell:dmCell AtIndexPath:indexPath];
    
    return dmCell;
}

- (void)updateCell:(MBSeparatedDirectMessageUserTableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedMessagesDict = [self.dataSource objectAtIndex:indexPath.row];
    NSString *userKey = [selectedMessagesDict stringForKey:@"user"];
    NSMutableArray *messages = [selectedMessagesDict mutableArrayForKey:@"messages"];
    MBDirectMessage *lastMessage = [messages lastObject];

    MBUser *user = [[MBUserManager sharedInstance] storedUserForKey:userKey];
    
    
    // timeInterval
    NSString *timeInterval = [NSString timeMarginWithDate:lastMessage.createdDate];
    [cell setDateString:timeInterval];
    
    // charaScreenNameView
    [cell setCharaScreenString:[MBTweetTextComposer attributedStringForTimelineUser:user charFont:[UIFont boldSystemFontOfSize:17.0f] screenFont:[UIFont systemFontOfSize:14.0f]]];
    
    // subtitleText
    [cell setSubtitleString:lastMessage.tweetText];
    
    // avatorImage
    [cell setUserIDStr:user.userIDStr];
    cell.avatorImageView.delegate = self;
    cell.avatorImageView.avatorImage = nil;
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:user.userIDStr];
    if (!avatorImage) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [MBImageDownloader downloadOriginImageWithURL:user.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:user.userIDStr];
                    
                    CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:cell.avatorImageView.layer.cornerRadius];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.avatorImageView.avatorImage = radiusImage;
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
                cell.avatorImageView.avatorImage = radiusImage;
            });
        });
    }
}

- (void)updateTableViewDataSource:(NSArray *)messages
{
    if (/*0 == [messages count] ||*/ nil == messages) {
        [self.refreshControl endRefreshing];
        [self removeLoadingView];
    } else {
        
        __weak MBSeparatedDirectMessageUserViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            weakSelf.dataSource = [[MBDirectMessageManager sharedInstance] separatedMessages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [weakSelf.refreshControl endRefreshing];
                [weakSelf removeLoadingView];
            });
        });
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; /* delete 処理が がうまくいかないので */
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        
        //[self.dataSource removeObjectAtIndex:indexPath.row];
        
        NSDictionary *selectedMessagesDict = [self.dataSource objectAtIndex:indexPath.row];
        NSString *userKey = [selectedMessagesDict stringForKey:@"user"];
        
        NSArray *messages = [[MBDirectMessageManager sharedInstance] separatedMessagesForKey:userKey];
        for (MBDirectMessage *message in messages) {
            [self.aoAPICenter postDestroyDirectMessagesRequireID:[[message tweetID] unsignedLongLongValue]];
        }
        [[MBDirectMessageManager sharedInstance] removeSeparatedMessagesForKey:userKey];
        self.dataSource = [[MBDirectMessageManager sharedInstance] separatedMessages];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

#pragma mark - Navigation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedMessagesDict = [self.dataSource objectAtIndex:indexPath.row];
    NSString *userKey = [selectedMessagesDict stringForKey:@"user"];
    MBUser *partner = [[MBUserManager sharedInstance] storedUserForKey:userKey];
    NSMutableArray *messages = [[MBDirectMessageManager sharedInstance] separatedMessagesForKey:userKey];
    
    MBIndividualDirectMessagesViewController *individualViewController = [[MBIndividualDirectMessagesViewController alloc] init];
    
    [individualViewController setPartner:partner];
    [individualViewController setConversation:messages];
    [self.navigationController pushViewController:individualViewController animated:YES];
}

#pragma mark APICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedDirectMessages:(NSArray *)messages
{
    [self updateTableViewDataSource:messages];
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUserIDs:(NSArray *)userIDs next:(NSNumber *)next previous:(NSNumber *)previous
{
    if (0 < userIDs.count && next && previous) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for (NSNumber *userID in userIDs) {
                [self.followerIDManager addRequireLoadingIDs:userID];
            }
            self.followerIDManager.cursor = next;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                long long cursor = self.followerIDManager.cursor.longLongValue;
                if (0 != cursor) {
                    [self fetchFollowerIDs];
                } else if (0 == cursor) {
                    [self fetchUsersForStoredIds];
                }
            });
        });
    }
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users
{
    if (0 < users.count) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for (MBUser *user in users) {
                [self.followerIDManager.requireLoadingIDs removeObjectForKey:user.userID];
                [self.followerIDManager.userIDs setObject:user.userIDStr forKey:user.userID];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchUsersForStoredIds];
            });
        });
    }
}

#pragma mark IndividualViewController Delegate

- (void)sendMessageIndividualDirectMessagesViewController:(MBIndividualDirectMessagesViewController *)controller
{
    self.dataSource = [[MBDirectMessageManager sharedInstance] separatedMessages].mutableCopy;
    [self.tableView reloadData];
}

#pragma mark MyAccountViewController
- (void)dismissAccountsViewController:(MBMyAccountsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
    controller = nil;
}

#pragma mark MBAvatorImageView Delegate
- (void)imageViewDidClick:(MBAvatorImageView *)imageView userID:(NSNumber *)userID userIDStr:(NSString *)userIDStr
{
    [imageView setIsSelected:YES withAnimated:NO];
    
    MBUser *selectedUser = [[MBUserManager sharedInstance] storedUserForKey:userIDStr];
    MBDetailUserViewController *userViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
    [userViewController setUser:selectedUser];
    if (nil == selectedUser) {
        [userViewController setUserID:userID];
    } else {
        [userViewController setUserID:nil];
    }
    [self.navigationController pushViewController:userViewController animated:YES];
}

@end

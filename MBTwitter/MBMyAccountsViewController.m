//
//  MBMyAccountsViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMyAccountsViewController.h"
#import "MBUserTimelineViewController.h"
#import "MBFollowingViewController.h"
#import "MBFollowerViewController.h"
#import "MBFavoritesViewController.h"
#import "MBOtherUserListViewController.h"

#import "MBDetailUserInfomationTableViewCell.h"
#import "MBProfileAvatorView.h"
#import "MBAvatorImageView.h"

#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBTwitterAccesser.h"
#import "MBUserManager.h"
#import "MBUser.h"
#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"


static NSString *avatorInfomationTableViewCellIdentifier = @"MBDetailUserInfomationTableViewCellIdentifier";

@interface MBMyAccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) NSArray *accounts;
@property (nonatomic) MBUser *currentUser;

@end

@implementation MBMyAccountsViewController
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
- (void)setCurrentUser:(MBUser *)currentUser
{
    _currentUser = currentUser;
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View
- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^ (NSNotification *notification) {
        _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        _aoAPICenter.delegate = self;
        NSLog(@"change Account in MyAccountViewController");
        
    }];
    
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *avatorInfomationNib = [UINib nibWithNibName:@"MBDetailUserInfomationTableViewCell" bundle:nil];
    [self.tableView registerNib:avatorInfomationNib forCellReuseIdentifier:avatorInfomationTableViewCellIdentifier];
    
}

- (void)commonConfigureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didPushCloseButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New Account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushAccountButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonConfigureModel];
    [self commonConfigureView];
    
    [self.twitterAccessor isAuthorized];
    
    self.accounts = [MBAccountManager sharedInstance].accounts;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    MBUser *currentUser = [[MBUserManager sharedInstance] storedUserForKey:currentAccount.userID];
    
    if (currentUser) {
        [self setCurrentUser:currentUser];
    } else {
        [self.aoAPICenter getUser:0 screenName:currentAccount.screenName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)requestAccessForDeviceAccount
{
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (accountManager == nil) {
        
    }
    
    [accountManager requestAccessToAccountWithCompletionHandler:^(BOOL granted, NSArray *accounts, NSError *error) {
        if (!granted) {
            return;
        }
        
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^(){
            for (ACAccount *account in accounts) {
                [self.twitterAccessor requestReverseRequestTokenWithAccount:account];
            }
        });
        
    }];
}

- (void)downloadBannerImageForCell:(MBDetailUserInfomationTableViewCell *)cell
{NSLog(@"bannerURL = %@", self.currentUser.urlAtProfileBanner);
    if (self.currentUser.urlAtProfileBanner) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadBannerImageMobileRetina:self.currentUser.urlAtProfileBanner completionHandler:^(UIImage *image, NSData *imageData) {
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.bannerImageView.image = image;
                    });
                }
            }failedHandler:^(NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}

- (void)downloadAvatorImaeForCell:(MBDetailUserInfomationTableViewCell *)cell
{
    if (self.currentUser.urlHTTPSAtProfileImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [MBImageDownloader downloadOriginImageWithURL:self.currentUser.urlHTTPSAtProfileImage completionHandler:^ (UIImage *image, NSData *imageData) {
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:self.currentUser.userIDStr];
                    UIImage *radiusImage = [self applyImage:image ForAvatorViewInCell:cell];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.profileAvatorView.avatorImageView.image = radiusImage;
                    });
                }
            }failedHandler:^ (NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}

- (UIImage *)applyImage:(UIImage *)image ForAvatorViewInCell:(MBDetailUserInfomationTableViewCell *)cell
{
    CGSize imageSize = CGSizeMake(cell.profileAvatorView.avatorImageView.frame.size.width, cell.profileAvatorView.avatorImageView.frame.size.height);
    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:cell.profileAvatorView.avatorImageView.layer.cornerRadius];
    
    return radiusImage;
}

#pragma mark -
#pragma mark Button Action

- (void)didPushCloseButton
{
    if ([_delegate respondsToSelector:@selector(dismissAccountsViewController:animated:)]) {
        [_delegate dismissAccountsViewController:self animated:YES];
    }
}

- (void)didPushAccountButton
{
    MBAuthorizationViewController *authorizationViewController = [[MBAuthorizationViewController alloc] initWithNibName:@"AuthorizationView" bundle:nil];
    authorizationViewController.delegate = self;
    MBTwitterAccesser *newAccesser = [[MBTwitterAccesser alloc] init];
    authorizationViewController.twitterAccesser = newAccesser;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authorizationViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushDeleteButton
{
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    [accountManager deleteAllAccount];
    self.accounts = [MBAccountManager sharedInstance].accounts;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView DataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleForHeader = nil;
    if (0 == section) {
        titleForHeader = NSLocalizedString(@"Accounts", nil);
    } else if (1 == section) {
        titleForHeader = NSLocalizedString(@"Selected Account", nil);
    }
    
    return titleForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat defaultHeifht = 44.0f;
    CGFloat heightForRow = defaultHeifht;
    if (1 == indexPath.section) {
        heightForRow = 160.0f;
    }
    
    return heightForRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (0 == section) {
        numberOfRows = [self.accounts count];
    } else if (1  == section) {
        numberOfRows = 1;
    } else if (2 == section) {
        numberOfRows = 5;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *accountsCellIdentifier = @"AccountsCell";
    static NSString *userDataCellIdentifier = @"UserDataCell";
    UITableViewCell *cell;
    
    if (0 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:accountsCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountsCellIdentifier];
        }
        [self updateCell:cell atIndexPath:indexPath];
    } else if (1 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:avatorInfomationTableViewCellIdentifier];
        [self updateAvatorInformationCell:(MBDetailUserInfomationTableViewCell *)cell atIndexPath:indexPath];
    } else if (2 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:userDataCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:userDataCellIdentifier];
        }
        [self updateUserDataCell:cell atIndexPath:indexPath];
    }
    
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    MBAccount *account = [self.accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = account.screenName;
    if ([currentAccount.userID isEqualToString:account.userID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)updateAvatorInformationCell:(MBDetailUserInfomationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell setUser:self.currentUser];
    [cell updateCellContentsView];
    
    [self downloadBannerImageForCell:cell];
    
    UIImage *cachedImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:self.currentUser.userIDStr defaultImage:nil];
    cell.profileAvatorView.avatorImageView.image = cachedImage;
    if (!cachedImage) {
        [self downloadAvatorImaeForCell:cell];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *avatorImage = [self applyImage:cachedImage ForAvatorViewInCell:cell];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.profileAvatorView.avatorImageView.image = avatorImage;
            });
        });
    }
}

- (void)updateUserDataCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfRow = indexPath.row;
    NSString *textLabel;
    NSInteger detailInteger = 0;
    
    if (0 == numberOfRow) {
        textLabel = NSLocalizedString(@"All Tweets", nil);
        detailInteger = self.currentUser.tweetCount;
    } else if (1 == numberOfRow) {
        textLabel = NSLocalizedString(@"Following", nil);
        detailInteger = self.currentUser.followsCount;
    } else if (2 == numberOfRow) {
        textLabel = NSLocalizedString(@"Follower", nil);
        detailInteger = self.currentUser.followersCount;
    } else if (3 == numberOfRow) {
        textLabel = NSLocalizedString(@"Favorite", nil);
        detailInteger = self.currentUser.favoritesCount;
    } else if (4 == numberOfRow) {
        textLabel = NSLocalizedString(@"List", nil);
        detailInteger = self.currentUser.listedCount;
    } else {
        
    }
    
    cell.textLabel.text = textLabel;
    detailInteger = (0 <= detailInteger) ? detailInteger : 0;
    if (4 != numberOfRow) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", detailInteger];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        [[MBAccountManager sharedInstance] selectAccountAtIndex:indexPath.row];
        MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
        MBUser *currentUser = [[MBUserManager sharedInstance] storedUserForKey:currentAccount.userID];
        if (currentUser) {
            [self setCurrentUser:currentUser];
        } else {
            [_aoAPICenter getUser:0 screenName:[MBAccountManager sharedInstance].currentAccount.screenName];
        }
        
    } else if (1 == indexPath.section) {
        return;
    } else if (2 == indexPath.section) {
        NSInteger row = indexPath.row;
        if (0 == row) {
            MBUserTimelineViewController *userTimelineViewController = [[MBUserTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
            [userTimelineViewController setUser:self.currentUser];
            [self.navigationController pushViewController:userTimelineViewController animated:YES];
            
        } else if (1 == row) {
            MBFollowingViewController *followingViewController = [[MBFollowingViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
            [followingViewController setUser:self.currentUser];
            [self.navigationController pushViewController:followingViewController animated:YES];
            
        } else if (2 == row) {
            MBFollowerViewController *followerViewController = [[MBFollowerViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
            [followerViewController setUser:self.currentUser];
            [self.navigationController pushViewController:followerViewController animated:YES];
            
        } else if (3 == row) {
            MBFavoritesViewController *favoriteViewController = [[MBFavoritesViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
            [favoriteViewController setUser:self.currentUser];
            [self.navigationController pushViewController:favoriteViewController animated:YES];
            
        } else if (4 == row) {
            MBOtherUserListViewController *listViewController = [[MBOtherUserListViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
            [listViewController setUser:self.currentUser];
            [self.navigationController pushViewController:listViewController animated:YES];
            
        }
    }
    
}

#pragma mark - 
#pragma mark AuthorizationViewController Delegate
- (void)dismissAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

- (void)succeedAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    NSInteger lastIndex = [[MBAccountManager sharedInstance].accounts count] - 1;
    [[MBAccountManager sharedInstance] selectAccountAtIndex:lastIndex];
    
    [self.tableView reloadData];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users
{
    MBUser *user = [users firstObject];
    if (user) {
        self.currentUser = user;
    }
    NSLog(@"%@ count = %d", user.userIDStr, user.tweetCount);
}

@end

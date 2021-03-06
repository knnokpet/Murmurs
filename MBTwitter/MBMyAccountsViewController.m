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

#import "MBAppDelegate.h"

#import "MBMyAccountsTableViewCell.h"
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


static NSString *accountsTableViewCellIdentifier = @"MyAccountsTableViewCellIdentifier";
static NSString *avatorInfomationTableViewCellIdentifier = @"MBDetailUserInfomationTableViewCellIdentifier";

static NSString *titleKey = @"TitleKey";
static NSString *countKey = @"CountKey";
static NSString *imageKey = @"ImageKey";

@interface MBMyAccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) NSArray *accounts;
@property (nonatomic) NSMutableArray *dataSource;
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
    
    [self configureDataSource];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View
- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    
    [self receiveChangedAccountNotification];
}

- (void)configureDataSource
{
    self.dataSource = [NSMutableArray array];
    
    self.accounts = [MBAccountManager sharedInstance].accounts;
    if (!self.accounts) {
        return;
    }
    [self.dataSource addObject:self.accounts];
    
    if (!self.currentUser) {
        return;
    }
    [self.dataSource addObject:@[self.currentUser]];
    
    /* // 自身のプロテクトアカウントへのリクエストの照認/拒否のための API が存在しないので実装できない。
    if (self.currentUser.isSentRequestToProtectedUser) {
        NSString *followRequest = NSLocalizedString(@"Follow Request", nil);
        [self.dataSource addObject:@[followRequest]];
    }*/
    
    [self.dataSource addObject:[self currentUserData]];
}

- (NSArray *)currentUserData
{
    NSDictionary *tweetDict = [self concreateUserDictWithTitle:NSLocalizedString(@"Tweets", nil) count:self.currentUser.tweetCount image:[UIImage imageNamed:@"Tweet-Cell-blue"]];
    NSDictionary *followingDict = [self concreateUserDictWithTitle:NSLocalizedString(@"Following", nil) count:self.currentUser.followsCount image:[UIImage imageNamed:@"Man-Cell-blue"]];
    NSDictionary *followerDict = [self concreateUserDictWithTitle:NSLocalizedString(@"Follower", nil) count:self.currentUser.followersCount image:[UIImage imageNamed:@"Man-Cell-blue"]];
    NSDictionary *favoDict = [self concreateUserDictWithTitle:NSLocalizedString(@"Favorite", nil) count:self.currentUser.favoritesCount image:[UIImage imageNamed:@"Favorite-Cell-blue"]];
    NSDictionary *listDict = [self concreateUserDictWithTitle:NSLocalizedString(@"List", nil) count:self.currentUser.listedCount image:[UIImage imageNamed:@"List-Cell-blue"]];
    
    NSArray *userData = @[tweetDict, followingDict, followerDict, favoDict, listDict];
    return userData;
}

- (NSDictionary *)concreateUserDictWithTitle:(NSString *)title count:(NSInteger)count image:(UIImage *)image
{
    NSNumber *countNumber = [NSNumber numberWithInteger:count];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:@[title, countNumber, image] forKeys:@[titleKey, countKey, imageKey]];
    return infoDict;
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *avatorInfomationNib = [UINib nibWithNibName:@"MBDetailUserInfomationTableViewCell" bundle:nil];
    [self.tableView registerNib:avatorInfomationNib forCellReuseIdentifier:avatorInfomationTableViewCellIdentifier];
    UINib *accountsCellNib = [UINib nibWithNibName:@"MBMyAccountsTableViewCell" bundle:nil];
    [self.tableView registerNib:accountsCellNib forCellReuseIdentifier:accountsTableViewCellIdentifier];
    
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
    
    [self configureDataSource];
    
    self.title = NSLocalizedString(@"Account", nil);
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
- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^ (NSNotification *notification) {
        _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        _aoAPICenter.delegate = self;
    }];
}

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
{
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

- (void)downloadAvatorImageForAccountsCell:(MBMyAccountsTableViewCell *)cell withUser:(MBUser *)user
{
    if (user.urlHTTPSAtProfileImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [MBImageDownloader downloadOriginImageWithURL:user.urlHTTPSAtProfileImage completionHandler:^ (UIImage *image, NSData *imageData) {
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:user.userIDStr];
                    CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                    CGFloat radius = cell.avatorImageView.layer.cornerRadius;
                    UIImage *radiusImage = [self applyedImage:image forViewSize:imageSize radius:radius];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.avatorImageView.image = radiusImage;
                    });
                }
            }failedHandler:^ (NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}

- (void)downloadAvatorImaeForInformationCell:(MBDetailUserInfomationTableViewCell *)cell
{
    if (self.currentUser.urlHTTPSAtProfileImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [MBImageDownloader downloadOriginImageWithURL:self.currentUser.urlHTTPSAtProfileImage completionHandler:^ (UIImage *image, NSData *imageData) {
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:self.currentUser.userIDStr];
                    CGSize imageSize = CGSizeMake(cell.profileAvatorView.avatorImageView.bounds.size.width, cell.profileAvatorView.avatorImageView.bounds.size.height);
                    CGFloat radius = cell.profileAvatorView.avatorImageView.layer.cornerRadius;
                    UIImage *radiusImage = [self applyedImage:image forViewSize:imageSize radius:radius];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.profileAvatorView.avatorImageView.image = radiusImage;
                    });
                }
            }failedHandler:^ (NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}

- (UIImage *)applyedImage:(UIImage *)image forViewSize:(CGSize)imageSize radius:(CGFloat)imageRadius
{
    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:imageRadius];
    return radiusImage;
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

/* For Testing */
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
    return 1; //[self.dataSource count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleForHeader = nil;
    if (0 == section) {
        titleForHeader = NSLocalizedString(@"Accounts", nil);
    } else if (1 == section) {
        MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
        titleForHeader = currentAccount.screenName;
    }
    
    return titleForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat defaultHeifht = 44.0f;
    CGFloat heightForRow = defaultHeifht;
    if (indexPath.section == 0) {
        heightForRow = 36.0f + 8.0f * 2;
    }else if (1 == indexPath.section) {
        heightForRow = 160.0f;
    }
    
    return heightForRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataSourceAtSection = [self.dataSource objectAtIndex:section];
    
    return [dataSourceAtSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *accountsCellIdentifier = @"AccountsCell";
    static NSString *userDataCellIdentifier = @"UserDataCell";
    /*static NSString *requestCellIdentifier = @"RequestCell";  unused */
    UITableViewCell *cell;
    
    if (0 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:accountsTableViewCellIdentifier];
        [self updateCell:(MBMyAccountsTableViewCell *)cell atIndexPath:indexPath];
        
    } else if (1 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:avatorInfomationTableViewCellIdentifier];
        [self updateAvatorInformationCell:(MBDetailUserInfomationTableViewCell *)cell atIndexPath:indexPath];
        
    } else if (2 == indexPath.section) {
        /*
        if (self.currentUser.isSentRequestToProtectedUser) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:requestCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:requestCellIdentifier];
            }
            [self updateFollowRequestCell:cell atIndexPath:indexPath];
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:userDataCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:userDataCellIdentifier];
            }
            [self updateUserDataCell:cell atIndexPath:indexPath];
        }*/
        cell = [self.tableView dequeueReusableCellWithIdentifier:userDataCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:userDataCellIdentifier];
        }
        [self updateUserDataCell:cell atIndexPath:indexPath];
        
    } else if (3 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:userDataCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:userDataCellIdentifier];
        }
        [self updateUserDataCell:cell atIndexPath:indexPath];
    }
    
    
    return cell;
}

- (void)updateCell:(MBMyAccountsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    MBAccount *account = [self.accounts objectAtIndex:indexPath.row];
    MBUser *user = [[MBUserManager sharedInstance] storedUserForKey:account.userID];
    cell.characterNameLabel.text = account.screenName;
    if ([currentAccount.userID isEqualToString:account.userID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UIImage *cachedImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:user.userIDStr defaultImage:nil];
    if (!cachedImage) {
        [self downloadAvatorImageForAccountsCell:cell withUser:user];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
            CGFloat radius = cell.avatorImageView.layer.cornerRadius;
            UIImage *radiusImage = [self applyedImage:cachedImage forViewSize:imageSize radius:radius];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatorImageView.image = radiusImage;
            });
        });
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
        [self downloadAvatorImaeForInformationCell:cell];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *avatorImage = [self applyImage:cachedImage ForAvatorViewInCell:cell];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.profileAvatorView.avatorImageView.image = avatorImage;
            });
        });
    }
}

- (void)updateFollowRequestCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = NSLocalizedString(@"Follow Request", nil);
    
}

- (void)updateUserDataCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSArray *dataSourceAtSection = [self.dataSource objectAtIndex:indexPath.section];
    NSDictionary *dataDict = [dataSourceAtSection objectAtIndex:indexPath.row];
    NSString *textLabel = [dataDict objectForKey:titleKey];
    NSNumber *countNumber = [dataDict objectForKey:countKey];
    UIImage *cellImage = [dataDict objectForKey:imageKey];
    NSInteger detailInteger = [countNumber integerValue];
    
    cell.textLabel.text = textLabel;
    detailInteger = (0 <= detailInteger) ? detailInteger : 0;
    if (4 != indexPath.row) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)detailInteger];
    }
    
    cell.imageView.image = cellImage;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        MBUser *previousUser = [[MBUserManager sharedInstance] storedUserForKey:[MBAccountManager sharedInstance].currentAccount.userID];
        
        [[MBAccountManager sharedInstance] selectAccountAtIndex:indexPath.row];
        MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
        MBUser *currentUser = [[MBUserManager sharedInstance] storedUserForKey:currentAccount.userID];
        if ([currentUser.userID compare:previousUser.userID] != NSOrderedSame) {
            MBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate popToRootViewControllerForAllTabbedController:NO];
        }
        if (currentUser) {
            [self setCurrentUser:currentUser];
        } else {
            [_aoAPICenter getUser:0 screenName:[MBAccountManager sharedInstance].currentAccount.screenName];
        }
        
    } else if (1 == indexPath.section) {
        return;
    } else if (2 == indexPath.section) {
        
        if (self.currentUser.isSentRequestToProtectedUser || self.dataSource.count == 4) {
            ;
        } else {
            [self didSelectUserDataCellAtIndexPath:indexPath];
        }
        
    } else if (3 == indexPath.section) {
        [self didSelectUserDataCellAtIndexPath:indexPath];
    }
}

- (void)didSelectUserDataCellAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark -
#pragma mark AuthorizationViewController Delegate
- (void)dismissAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

- (void)succeedAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    NSInteger lastIndex = [[MBAccountManager sharedInstance].accounts count] - 1;
    if (lastIndex < 0) {
        lastIndex = 0;
    }
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
}

@end

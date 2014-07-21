//
//  MBDetailUserViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailUserViewController.h"
#import "MBUserTimelineViewController.h"
#import "MBFollowingViewController.h"
#import "MBFollowerViewController.h"
#import "MBFavoritesViewController.h"
#import "MBOtherUserListViewController.h"

#import "MBRelationshipManager.h"
#import "MBUser.h"
#import "MBEntity.h"
#import "MBURLLink.h"
#import "MBRelationship.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"
#import "MBTweetTextComposer.h"

#import "MBProfileAvatorView.h"
#import "MBProfileDesciptionView.h"
#import "MBProfileInfomationView.h"
#import "MBDetailUserActionTableViewCell.h"

static NSString *detailUserTableViewCellIdentifier = @"MBDetailUserTableViewCellIdentifier";

@interface MBDetailUserViewController () <UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _headerImageOffSet;
}

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@property (nonatomic) UIImageView *headerImageView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) MBProfileAvatorView *profileAvatorView;
@property (nonatomic) MBProfileDesciptionView *profileDescriptionView;
@property (nonatomic) MBProfileInfomationView *profileInformationView;
@property (nonatomic) UIPageControl *pageControl;

@property (nonatomic) NSMutableArray *otherActions;

@end


@implementation MBDetailUserViewController
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

- (void)dealloc
{
    [self.tableView setDelegate:nil]; // scrollView のデリゲートが呼ばれて堕ちるため
    [self.scrollView setDelegate:nil];
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setUser:(MBUser *)user
{
    _user = user;
    
}

- (void)setUserID:(NSNumber *)userID
{
    _userID = userID;
}

#pragma mark -
#pragma mark View
- (void)configureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    
}

- (void)configureView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    CGFloat tableHeaderHeight = 160.0f;
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, tableHeaderHeight)];
    tableHeaderView.backgroundColor = [UIColor darkGrayColor];
    self.tableView.tableHeaderView = tableHeaderView;
    
    
    _headerImageOffSet = tableHeaderHeight;
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableHeaderHeight)];
    [self.tableView.tableHeaderView addSubview:self.headerImageView];
    
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, navigationHeight, self.view.frame.size.width, tableHeaderHeight)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.delegate = self;
    NSInteger pageCount = [self numberOfPage];
    
    [self.scrollView setContentSize:CGSizeMake(pageCount * self.view.frame.size.width, tableHeaderHeight)];
    [self.tableView.tableHeaderView addSubview:self.scrollView];
    
    self.profileAvatorView = [[MBProfileAvatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableHeaderHeight)];
    self.profileAvatorView.characterName = self.user.characterName;
    self.profileAvatorView.screenName = self.user.screenName;
    [self.scrollView addSubview:self.profileAvatorView];
    
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:self.user.userIDStr];
    if (nil == avatorImage) {
        [self downloadAvatorImage];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            CGSize imageSize = CGSizeMake(self.profileAvatorView.avatorImageView.frame.size.width, self.profileAvatorView.avatorImageView.frame.size.height);
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:avatorImage size:imageSize radius:self.profileAvatorView.avatorImageView.layer.cornerRadius];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileAvatorView.avatorImageView.image = radiusImage;
                [self.profileAvatorView setNeedsDisplay];
            });
        });
    }
    [self downloadBannerImage];
    
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(0, self.scrollView.frame.size.height - 30, self.view.frame.size.width, 30);
    [self.pageControl addTarget:self action:@selector(pageControll:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = YES;
    [tableHeaderView addSubview:self.pageControl];
    
    [self configureDescriptionView];
    [self configureInfomationView];
}

- (void)configureDescriptionView
{
    if (!self.user) {
        return;
    }
    
    if (0 < self.user.desctiprion.length) {
        CGRect profileFrame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.scrollView.frame.size.height);
        self.profileDescriptionView = [[MBProfileDesciptionView alloc] initWithFrame:profileFrame];
        NSAttributedString *descriptionText = [MBTweetTextComposer attributedStringForUser:self.user linkColor:nil];
        [self.profileDescriptionView setAttributedString:descriptionText];
        [self.scrollView addSubview:self.profileDescriptionView];
    }
}

- (void)configureInfomationView
{
    if (!self.user) {
        return;
    }
    
    if (0 < self.user.urlAtProfile.length || 0 < self.user.location.length) {
        CGFloat xOrigin = self.view.frame.size.width + self.profileDescriptionView.frame.size.width;
        self.profileInformationView = [[MBProfileInfomationView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.view.frame.size.width, self.scrollView.frame.size.height)];
        [self.profileInformationView setLocationText:self.user.location];
        MBURLLink *urlInProfile = self.user.entity.urls.firstObject;
        [self.profileInformationView setUrlText:urlInProfile.displayText];
        [self.scrollView addSubview:self.profileInformationView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureModel];
    [self configureView];
    [self configureOtherActions];
    
    if (self.user.requireLoading) {
        [self.aoAPICenter getUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
    } else if (nil != self.userID) {
        [self.aoAPICenter getUser:[self.userID unsignedLongLongValue] screenName:nil];
    }
    
    if(NO == self.user.requireLoading && self.user.userID && !self.user.relationship) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray *requiredIDs = [[[MBAccountManager sharedInstance].currentAccount relationshipManger] requiredLoadingRelationshipUserIDs:99];
            NSMutableArray *mRequiredIDs = [NSMutableArray arrayWithArray:requiredIDs];
            [mRequiredIDs addObject:self.user.userID];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.aoAPICenter getRelationshipsOfMyAccountsWith:mRequiredIDs];
            });
        });
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    if (selectedIndex) {
        [self.tableView deselectRowAtIndexPath:selectedIndex animated:animated];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods

- (void)downloadBannerImage
{
    if (self.user.urlAtProfileBanner) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [MBImageDownloader downloadBannerImageMobileRetina:self.user.urlAtProfileBanner completionHandler:^ (UIImage *image, NSData *imageData){
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.headerImageView.image = image;
                        [self.headerImageView setNeedsDisplay];
                        
                    });
                }
                
            }failedHandler:^ (NSURLResponse *response, NSError *error) {
                NSLog(@"image error %@ code %lu", error.description, (unsigned long)error.code);
            }];
        });
    }
}

- (void)downloadAvatorImage
{
    
    if (self.user.urlHTTPSAtProfileImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [MBImageDownloader downloadOriginImageWithURL:self.user.urlHTTPSAtProfileImage completionHandler:^ (UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:self.user.userIDStr];
                    CGSize imageSize = CGSizeMake(self.profileAvatorView.avatorImageView.frame.size.width, self.profileAvatorView.avatorImageView.frame.size.height);
                    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:self.profileAvatorView.avatorImageView.layer.cornerRadius];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.profileAvatorView.avatorImageView.image = radiusImage;
                        [self.profileAvatorView setNeedsDisplay];
                    });
                }
                
            }failedHandler:^(NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}

- (void)pageControll:(id)sender
{
    CGRect frame = self.view.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (NSInteger)numberOfPage
{
    NSInteger pageCount = 1;
    if (0 < self.user.desctiprion.length && (0 < self.user.urlAtProfile.length || 0 < self.user.location.length)) {
        pageCount = 3;
    } else if (0 < self.user.desctiprion.length || 0 < self.user.urlAtProfile.length || 0 < self.user.location.length) {
        pageCount = 2;
    }
    
    return pageCount;
}

- (void)updateViews
{
    self.profileAvatorView.characterName = self.user.characterName;
    self.profileAvatorView.screenName = self.user.screenName;
    
    [self configureDescriptionView];
    [self configureInfomationView];
    
    NSInteger pageCount = [self numberOfPage];
    [self.scrollView setContentSize:CGSizeMake(pageCount * self.view.frame.size.width, self.scrollView.frame.size.height)];
    [self.pageControl setNumberOfPages:pageCount];
    
    [self.scrollView setNeedsDisplay];
    [self.tableView reloadData];
    
    if (nil == self.headerImageView.image && nil != self.user.urlAtProfileBanner) {
        [self downloadBannerImage];
    }
    if (nil == self.profileAvatorView.avatorImageView.image && nil != self.user.urlHTTPSAtProfileImage) {
        [self downloadAvatorImage];
    }
    
    if(NO == self.user.requireLoading && self.user.userID && !self.user.relationship) {
        [self.aoAPICenter getRelationshipsOfMyAccountsWith:@[self.user.userID]];
    }
}

- (void)configureOtherActions
{
    self.otherActions = [NSMutableArray array];
    if (self.user.relationship) {
        MBRelationship *relation = self.user.relationship;
        
        NSString *listAction = NSLocalizedString(@"Add / Remove List", nil);
        NSString *followAction;
        if (relation.isFollowing) {
            followAction = NSLocalizedString(@"UnFollow", nil);
        } else if (relation.sentFollowRequest) {
            followAction = NSLocalizedString(@"Cancel Request", nil);
        }
        
        NSString *blockAction;
        if (relation.isBlocking) {
            blockAction = NSLocalizedString(@"Cancel Blocking", nil);
        } else {
            blockAction = NSLocalizedString(@"Block User", nil);
        }
        
        NSString *spamAction = NSLocalizedString(@"Spam Report", nil);
        
        NSString *muteAction;
        if (relation.isMuting) {
            muteAction = NSLocalizedString(@"Cancel Mute", nil);
        } else {
            muteAction = NSLocalizedString(@"Mute", nil);
        }
        
        
        if (relation.isBlocking) {
            [self.otherActions addObject:blockAction];
            [self.otherActions addObject:spamAction];
        } else {
            [self.otherActions addObject:listAction];
            if (followAction) {
                [self.otherActions addObject:followAction];
            }
            [self.otherActions addObject:blockAction];
            //[self.otherActions addObject:muteAction];
            [self.otherActions addObject:spamAction];
        }
    }
}

#pragma mark Button Action
- (IBAction)didPushFollowButton:(id)sender {
    [self.aoAPICenter postFollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}
- (IBAction)didPushUnfollowButton:(id)sender {
    [self.aoAPICenter postUnfollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushFollowButton
{
    [self.aoAPICenter postFollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushUnFollowButton
{
    [self.aoAPICenter postUnfollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushCancelBlockingButton
{
    [self.aoAPICenter postDestroyBlockForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushBlockButton
{
    [self.aoAPICenter postBlockForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushCancelMuteButton
{
    [self.aoAPICenter postDestroyMuteForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushMuteButton
{
    [self.aoAPICenter postMuteForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushSpamButton
{
    [self.aoAPICenter postSpamForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushReplyButton
{
    
}

- (void)didPushMessageButton
{
    
}


- (void)didPushOtherButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    for (NSString *buttonTitle in self.otherActions) {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Chancel", nil)];
    actionSheet.cancelButtonIndex = self.otherActions.count;
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark -
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 1;
    }
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell;
    
    if (0 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:detailUserTableViewCellIdentifier];
        if (!cell) {
            cell = [[MBDetailUserActionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailUserTableViewCellIdentifier];
        }
        [self updateActionCell:(MBDetailUserActionTableViewCell *)cell];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        [self updateCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)updateActionCell:(MBDetailUserActionTableViewCell *)cell
{
    if (self.user.relationship) {
        MBRelationship *relationship = self.user.relationship;
        
        BOOL canFollow = (relationship.isFollowing) ? NO : YES;
        cell.canFollow = canFollow;
        
        BOOL canMessage = (relationship.followdByTheUser) ? YES : NO;
        cell.canMessage = canMessage;
        
        cell.followsMyAccount = relationship.followdByTheUser;
        
        cell.sentFollowRequest = relationship.sentFollowRequest;
        
        cell.isBlocking = relationship.isBlocking;
        
        
    }
    
    // add Target
    [cell.followButton addTarget:self action:@selector(didPushFollowButton) forControlEvents:UIControlEventTouchUpInside];
    [cell.otherButton addTarget:self action:@selector(didPushOtherButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfRow = indexPath.row;
    NSString *textLabel;
    NSInteger detailInteger = 0;
    UIImage *cellImage;
    
    if (0 == numberOfRow) {
        textLabel = NSLocalizedString(@"Tweet", nil);
        detailInteger = self.user.tweetCount;
        cellImage = [UIImage imageNamed:@"Tweet-Cell"];
    } else if (1 == numberOfRow) {
        textLabel = NSLocalizedString(@"Following", nil);
        detailInteger = self.user.followsCount;
        cellImage = [UIImage imageNamed:@"Man-Cell"];
    } else if (2 == numberOfRow) {
        textLabel = NSLocalizedString(@"Follower", nil);
        detailInteger = self.user.followersCount;
        cellImage = [UIImage imageNamed:@"Man-Cell"];
    } else if (3 == numberOfRow) {
        textLabel = NSLocalizedString(@"Favorite", nil);
        detailInteger = self.user.favoritesCount;
        cellImage = [UIImage imageNamed:@"Favorite-Cell"];
    } else if (4 == numberOfRow) {
        textLabel = NSLocalizedString(@"List", nil);
        detailInteger = self.user.listedCount;
        cellImage = [UIImage imageNamed:@"List-Cell"];
    } else {
        
    }
    
    cell.textLabel.text = textLabel;
    cell.imageView.image = cellImage;
    // リストの数はユーザーが登録されているものしかとれないので表示しない
    detailInteger = (0 <= detailInteger) ? detailInteger : 0;
    if (4 != numberOfRow) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", detailInteger];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        return;
    }
    
    NSInteger row = indexPath.row;
    if (0 == row) {
        MBUserTimelineViewController *userTimelineViewController = [[MBUserTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
        userTimelineViewController.user = self.user;
        [self.navigationController pushViewController:userTimelineViewController animated:YES];
        
    } else if (1 == row) {
        MBFollowingViewController *followingViewController = [[MBFollowingViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
        [followingViewController setUser:self.user];
        [self.navigationController pushViewController:followingViewController animated:YES];
        
    } else if (2 == row) {
        MBFollowerViewController *followerViewController = [[MBFollowerViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
        [followerViewController setUser:self.user];
        [self.navigationController pushViewController:followerViewController animated:YES];
        
    } else if (3 == row) {
        MBFavoritesViewController *favoritesViewController = [[MBFavoritesViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
        [favoritesViewController setUser:self.user];
        [self.navigationController pushViewController:favoritesViewController animated:YES];
        
    } else if (4 == row) {
        MBOtherUserListViewController *otherListViewController = [[MBOtherUserListViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
        [otherListViewController setUser:self.user];
        [self.navigationController pushViewController:otherListViewController animated:YES];
        
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

#pragma mark -AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users
{
    MBUser *user = [users firstObject];
    if (user) {
        NSLog(@"screen %@ chara %@", user.screenName, user.characterName);
        [self setUser:user];
        
        if (requestType == MBTwitterFriendShipsCreateRequest) {
            if (self.user.isProtected) {
                self.user.relationship.sentFollowRequest = YES;
            } else {
                self.user.relationship.isFollowing = YES;
            }
        } else if (requestType == MBTwitterFriendShipsDestroyRequest) {
            self.user.relationship.isFollowing = NO;
            self.user.relationship.sentFollowRequest = NO;
        } else if (requestType == MBTwitterBlocksCreateRequest) {
            self.user.relationship.isBlocking = YES;
        } else if (requestType == MBTwitterBlocksDestroyRequest) {
            self.user.relationship.isBlocking = NO;
        } else if (requestType == MBTwitterMuteCreaterequest) {
            self.user.relationship.isMuting = YES;
        } else if (requestType == MBTwitterMuteDestroyRequest) {
            self.user.relationship.isMuting = NO;
        } else if (requestType == MBTwitterUsersReportSpamRequest) {
            self.user.relationship.isBlocking = YES;
        }
        
        [self configureOtherActions];
        [self updateViews];
    }
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center relationships:(NSArray *)relationships
{
    if(0 < relationships.count) {
        MBRelationshipManager *relationshipManager = [[MBAccountManager sharedInstance].currentAccount relationshipManger];
        for (MBRelationship *relationship in relationships) {
            [relationshipManager storeRelationship:relationship];
            if (NSOrderedSame == [self.user.userID compare:relationship.userID]) {
                self.user.relationship = relationship;
                NSLog(@"isf %hhd  sentFo %hhd fob %hhd ", relationship.isFollowing, relationship.sentFollowRequest, relationship.followdByTheUser);
                UITableViewCell *actionCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [self updateActionCell:(MBDetailUserActionTableViewCell *)actionCell];
                [self configureOtherActions];
            }
        }
        NSLog(@"relation count = %d", relationships.count);
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView == scrollView) {
        CGRect scrollViewFrame = self.scrollView.frame;
        
        scrollViewFrame.origin = scrollView.frame.origin;
        self.scrollView.frame = scrollViewFrame;
        
    } else if (self.scrollView == scrollView) {
        CGFloat viewWidth = self.view.bounds.size.width;
        
        CGFloat alpha = scrollView.contentOffset.x / viewWidth;
        if (alpha > 0.5) {
            alpha = 0.5;
        }
        UIColor *tlancerucentBlack = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
        self.scrollView.backgroundColor = tlancerucentBlack;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.tableView == scrollView) {
        ;
    } else if (self.scrollView == scrollView) {
        CGFloat viewWidth = self.view.frame.size.width;
        self.pageControl.currentPage = (self.scrollView.contentOffset.x + 1) / viewWidth;
    }
}

#pragma mark MBSelecting_MyListViewController Delegate
- (void)cancelSelectingListViewController:(MBSelecting_ListViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneSelectingListViewController:(MBSelecting_ListViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionsheetView Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Add / Remove List", nil)]) {
        MBSelecting_ListViewController *selectingListViewController = [[MBSelecting_ListViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
        selectingListViewController.delegate = self;
        [selectingListViewController setSelectingUser:self.user];
        UINavigationController *listNavigationController = [[UINavigationController alloc] initWithRootViewController:selectingListViewController];
        [self.navigationController presentViewController:listNavigationController animated:YES completion:nil];
        
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"UnFollow", nil)]) {
        [self didPushUnFollowButton];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Cancel Request", nil)]) {
        [self didPushUnFollowButton];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Cancel Blocking", nil)]) {
        [self didPushCancelBlockingButton];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Block User", nil)]) {
        [self didPushBlockButton];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Cancel Mute", nil)]) {
        
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Mute", nil)]) {
        
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Spam Report", nil)]) {
        [self didPushSpamButton];
    } else if (buttonIndex == actionSheet.cancelButtonIndex) {
        
    }
}

@end

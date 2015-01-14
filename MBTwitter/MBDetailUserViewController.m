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
#import "MBIndividualDirectMessagesViewController.h"

#import "MBRelationshipManager.h"
#import "MBUser.h"
#import "MBEntity.h"
#import "MBURLLink.h"
#import "MBRelationship.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"
#import "MBTweetTextComposer.h"
#import "MBDirectMessageManager.h"

#import "MBProtectedUserDetailView.h"
#import "MBProfileAvatorView.h"
#import "MBProfileDesciptionView.h"
#import "MBProfileInfomationView.h"
#import "MBDetailUserActionTableViewCell.h"

static NSString *detailUserTableViewCellIdentifier = @"MBDetailUserTableViewCellIdentifier";

typedef enum ActionSheetTag {
    PushMoreButtonTag = 0,
    PushUnfollowButtonTag,
    PushMuteButtonTag,
    PushBlockingButtonTag,
    PushSpamButtonTag,
    PushCancelBlockingButtonTag,
    PushCancelMuteButtonTag
    
} ActionSheetTag;

@interface MBDetailUserViewController () <UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _headerImageOffSet;
}

@property (nonatomic) UIImageView *headerImageView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) MBProfileAvatorView *profileAvatorView;
@property (nonatomic) MBProfileDesciptionView *profileDescriptionView;
@property (nonatomic) MBProfileInfomationView *profileInformationView;
@property (nonatomic) UIPageControl *pageControl;

@property (nonatomic) MBProtectedUserDetailView *protectedUserView;

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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableHeaderHeight)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.delegate = self;
    NSInteger pageCount = [self numberOfPage];
    
    [self.scrollView setContentSize:CGSizeMake(pageCount * self.view.frame.size.width, tableHeaderHeight)];
    [self.tableView.tableHeaderView addSubview:self.scrollView];
    
    [self configureAvatorView];
    
    
    self.pageControl = [[UIPageControl alloc] init];
    [self.pageControl addTarget:self action:@selector(pageControll:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = YES;
    [tableHeaderView addSubview:self.pageControl];
    CGRect pageControlRect = self.pageControl.frame;
    pageControlRect.origin = CGPointMake(self.view.bounds.size.width / 2,self.scrollView.bounds.size.height - 30);
    pageControlRect.size = CGSizeMake(self.pageControl.bounds.size.width, 30);
    self.pageControl.frame = pageControlRect;
    
    [self configureDescriptionView];
    [self configureInfomationView];
}

- (void)configureAvatorView
{
    self.profileAvatorView = [[MBProfileAvatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.headerImageView.bounds.size.height)];
    [self.scrollView addSubview:self.profileAvatorView];
    self.profileAvatorView.characterName = self.user.characterName;
    self.profileAvatorView.screenName = self.user.screenName;
    self.profileAvatorView.isProtected = self.user.isProtected;
    self.profileAvatorView.isVerified = self.user.isVerified;
    self.profileAvatorView.avatorImageView.avatorImage = nil;
    self.headerImageView.image = nil;
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:self.user.userIDStr];
    if (nil == avatorImage) {
        [self downloadAvatorImage];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            CGSize imageSize = CGSizeMake(self.profileAvatorView.avatorImageView.frame.size.width, self.profileAvatorView.avatorImageView.frame.size.height);
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:avatorImage size:imageSize radius:self.profileAvatorView.avatorImageView.layer.cornerRadius];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.profileAvatorView addAvatorImage:radiusImage animated:NO];
            });
        });
    }
    
    UIImage *bannerImage = [[MBImageCacher sharedInstance] cachedBannerImageForUserID:self.user.userIDStr];
    if (!bannerImage) {
        [self downloadBannerImage];
    } else {
        self.headerImageView.image = bannerImage;
    }
}

- (void)configureDescriptionView
{
    if (!self.user) {
        return;
    }
    
    CGRect profileFrame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.scrollView.frame.size.height);
    self.profileDescriptionView = [[MBProfileDesciptionView alloc] initWithFrame:profileFrame];
    [self.scrollView addSubview:self.profileDescriptionView];
    
    if (0 < self.user.desctiprion.length) {
        NSAttributedString *descriptionText = [MBTweetTextComposer attributedStringForUser:self.user linkColor:nil];
        [self.profileDescriptionView setAttributedString:descriptionText];
    }
}

- (void)configureInfomationView
{
    if (!self.user) {
        return;
    }

    CGFloat xOrigin = self.view.frame.size.width + self.profileDescriptionView.frame.size.width;
    self.profileInformationView = [[MBProfileInfomationView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.view.frame.size.width, self.scrollView.frame.size.height)];
    [self.scrollView addSubview:self.profileInformationView];
    
    if (0 < self.user.urlAtProfile.length || 0 < self.user.location.length) {
        [self.profileInformationView setLocationText:self.user.location];
        MBURLLink *urlInProfile = self.user.entity.urls.firstObject;
        [self.profileInformationView setUrlText:urlInProfile.displayText];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Profile", nil);
    
    [self configureModel];
    [self configureUserObject];
    [self fetchRelationship];
}

- (void)configureUserObject
{
    if (self.user.requireLoading) {
        [self.aoAPICenter getUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
    } else if (nil != self.userID) {
        [self.aoAPICenter getUser:[self.userID unsignedLongLongValue] screenName:nil];
    }
}

- (void)fetchRelationship
{
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
    
    [self configureView];
    [self configureOtherActions];

    [self deselectTableViewCellWithAnimated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)deselectTableViewCellWithAnimated:(BOOL)animated
{
    NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    if (selectedIndex) {
        [self.tableView deselectRowAtIndexPath:selectedIndex animated:animated];
    }
}

- (void)downloadBannerImage
{
    if (self.user.urlAtProfileBanner) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [MBImageDownloader downloadBannerImageMobileRetina:self.user.urlAtProfileBanner completionHandler:^ (UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeBannerImage:image forUserID:self.user.userIDStr];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.headerImageView.alpha = 0.0f;
                        self.headerImageView.image = image;
                        [UIView animateWithDuration:0.3f animations:^{
                            self.headerImageView.alpha = 1.0f;
                        }];
                    });
                }
                
            }failedHandler:^ (NSURLResponse *response, NSError *error) {
                
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
                        [self.profileAvatorView addAvatorImage:radiusImage animated:YES];
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
    [self configureAvatorView];
    [self configureDescriptionView];
    [self configureInfomationView];
    
    NSInteger pageCount = [self numberOfPage];
    [self.scrollView setContentSize:CGSizeMake(pageCount * self.view.frame.size.width, self.scrollView.frame.size.height)];
    [self.pageControl setNumberOfPages:pageCount];
    
    [self.scrollView setNeedsDisplay];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self showProtectedView:NO animated:YES];
    
    [self fetchRelationship];

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
        
        /* For Muting. unused.
        NSString *muteAction;
        if (relation.isMuting) {
            muteAction = NSLocalizedString(@"Cancel Mute", nil);
        } else {
            muteAction = NSLocalizedString(@"Mute", nil);
        }*/
        
        
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

- (void)showActionSheet:(UIActionSheet *)actionSheet
{
    if (self.tabBarController) {
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    } else {
        [actionSheet showInView:self.view];
    }
}

- (void)updateActionCell
{
    [self configureOtherActions];
    UITableViewCell *actionCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self updateActionCell:(MBDetailUserActionTableViewCell *)actionCell];
}

- (void)showProtectedView:(BOOL)shows animated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3f : 0.0f;
    CGFloat alpha = shows ? 1.0f : 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.protectedUserView setAlpha:alpha];
    }completion:^ (BOOL finished) {
        if (!shows && self.protectedUserView.superview) {
            [self.protectedUserView removeFromSuperview];
        }
    }];
}

#pragma mark Button Action
/*unused*/
- (IBAction)didPushFollowButton:(id)sender {
    [self.aoAPICenter postFollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}
- (IBAction)didPushUnfollowButton:(id)sender {
    [self.aoAPICenter postUnfollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}
/*unused*/

- (void)didPushFollowButton
{
    [self.aoAPICenter postFollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

- (void)didPushUnFollowButton
{
    NSString *title = NSLocalizedString(@"UnFollow User ?", nil);
    if (self.user.relationship.sentFollowRequest) {
        title = NSLocalizedString(@"Cancel Request ?", nil);
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"UnFollow", nil) otherButtonTitles:nil, nil];
    actionSheet.tag = PushUnfollowButtonTag;
    [self showActionSheet:actionSheet];
}

- (void)didPushCancelBlockingButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Cancel Blocking ?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Cancel Blocking", nil) otherButtonTitles:nil, nil];
    actionSheet.tag = PushCancelBlockingButtonTag;
    [self showActionSheet:actionSheet];
}

- (void)didPushBlockButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Block User ?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Block", nil) otherButtonTitles:nil, nil];
    actionSheet.tag = PushBlockingButtonTag;
    [self showActionSheet:actionSheet];
}

- (void)didPushCancelMuteButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Cancel Mute ?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Cancel Mute", nil) otherButtonTitles:nil, nil];
    actionSheet.tag = PushCancelMuteButtonTag;
    [self showActionSheet:actionSheet];
}

- (void)didPushMuteButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Mute this User ?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Mute", nil) otherButtonTitles:nil, nil];
    actionSheet.tag = PushMuteButtonTag;
    [self showActionSheet:actionSheet];
}

- (void)didPushSpamButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Send Spam Request ?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Send Spam Request", nil) otherButtonTitles:nil, nil];
    actionSheet.tag = PushSpamButtonTag;
    [self showActionSheet:actionSheet];
}

- (void)didPushReplyButton
{
    MBPostTweetViewController *postViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postViewController.delegate = self;
    [postViewController setScreenName:self.user.screenName];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushMessageButton
{
    if ([[MBDirectMessageManager sharedInstance] separatedMessages].count == 0) {
        [self.aoAPICenter getDeliveredDirectMessagesSinceID:0 maxID:0];
        [self.aoAPICenter getSentDirectMessagesSinceID:0 maxID:0];
    }
    
    NSMutableArray *messages = [[MBDirectMessageManager sharedInstance] separatedMessagesForKey:self.user.userIDStr];
    MBIndividualDirectMessagesViewController *messageViewController = [[MBIndividualDirectMessagesViewController alloc] init];
    [messageViewController setPartner:self.user];
    [messageViewController setConversation:messages];
    [self.navigationController pushViewController:messageViewController animated:YES];
}


- (void)didPushOtherButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.tag = PushMoreButtonTag;
    actionSheet.delegate = self;
    for (NSString *buttonTitle in self.otherActions) {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = self.otherActions.count;
    
    [self showActionSheet:actionSheet];
}

#pragma mark -
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    if (indexPath.section == 0) {
        ;
    }
    
    return height;
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
    // add Target
    [cell.tweetButton addTarget:self action:@selector(didPushReplyButton) forControlEvents:UIControlEventTouchUpInside];
    [cell.messageButton addTarget:self action:@selector(didPushMessageButton) forControlEvents:UIControlEventTouchUpInside];
    [cell.followButton addTarget:self action:@selector(didPushFollowButton) forControlEvents:UIControlEventTouchUpInside];
    [cell.otherButton addTarget:self action:@selector(didPushOtherButton) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    
    
    MBAccount *currentAccount = [MBAccountManager sharedInstance].currentAccount;
    if ([currentAccount.userID isEqualToString:self.user.userIDStr]) {
        cell.isMyAccount = YES;
    }
    
    [cell layoutIfNeeded];
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
        cellImage = [UIImage imageNamed:@"Tweet-Cell-blue"];
    } else if (1 == numberOfRow) {
        textLabel = NSLocalizedString(@"Following", nil);
        detailInteger = self.user.followsCount;
        cellImage = [UIImage imageNamed:@"Man-Cell-blue"];
    } else if (2 == numberOfRow) {
        textLabel = NSLocalizedString(@"Follower", nil);
        detailInteger = self.user.followersCount;
        cellImage = [UIImage imageNamed:@"Man-Cell-blue"];
    } else if (3 == numberOfRow) {
        textLabel = NSLocalizedString(@"Favorite", nil);
        detailInteger = self.user.favoritesCount;
        cellImage = [UIImage imageNamed:@"Favorite-Cell-blue"];
    } else if (4 == numberOfRow) {
        textLabel = NSLocalizedString(@"List", nil);
        detailInteger = self.user.listedCount;
        cellImage = [UIImage imageNamed:@"List-Cell-blue"];
    } else {
        
    }
    
    cell.textLabel.text = textLabel;
    cell.imageView.image = cellImage;
    // リストの数はユーザーが登録されているものしかとれないので表示しない
    if (4 != numberOfRow) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)detailInteger];
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        return;
    }
    
    // selected protected Account
    if (indexPath.section == 1 && self.user.isProtected && !self.user.relationship.followdByTheUser && self.user.relationship) {
        CGRect protectedRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        self.protectedUserView = [[MBProtectedUserDetailView alloc] initWithFrame:CGRectMake(protectedRect.origin.x, protectedRect.origin.y, self.view.bounds.size.width, 220)];
        self.protectedUserView.backgroundView = self.tableView;
        self.protectedUserView.alpha = 0.0f;
        [self.tableView addSubview:self.protectedUserView];
        [self.protectedUserView setOperationString:NSLocalizedString(@"Sent Follow Request!", nil)];
        [self.protectedUserView setDetailString:NSLocalizedString(@"This account is Protected. When a request is accepted, you can see the information", nil)];
        [self deselectTableViewCellWithAnimated:YES];
        [self showProtectedView:YES animated:YES];
        
        return;
    }
    
    NSInteger row = indexPath.row;
    if (0 == row) {
        MBUserTimelineViewController *userTimelineViewController = [[MBUserTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
        userTimelineViewController.user = self.user;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
        self.navigationItem.backBarButtonItem = backButton;
        
        [self.navigationController pushViewController:userTimelineViewController animated:YES];
        
    } else if (1 == row) {
        MBFollowingViewController *followingViewController = [[MBFollowingViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
        [followingViewController setUser:self.user];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
        self.navigationItem.backBarButtonItem = backButton;
        
        [self.navigationController pushViewController:followingViewController animated:YES];
        
    } else if (2 == row) {
        MBFollowerViewController *followerViewController = [[MBFollowerViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
        [followerViewController setUser:self.user];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
        self.navigationItem.backBarButtonItem = backButton;
        [self.navigationController pushViewController:followerViewController animated:YES];
        
    } else if (3 == row) {
        MBFavoritesViewController *favoritesViewController = [[MBFavoritesViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
        [favoritesViewController setUser:self.user];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
        self.navigationItem.backBarButtonItem = backButton;
        [self.navigationController pushViewController:favoritesViewController animated:YES];
        
    } else if (4 == row) {
        MBOtherUserListViewController *otherListViewController = [[MBOtherUserListViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
        [otherListViewController setUser:self.user];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
        self.navigationItem.backBarButtonItem = backButton;
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
        [self updateActionCell];
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
                
                [self updateActionCell];
                
            }
        }
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self showProtectedView:NO animated:YES];
}

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
    NSInteger tag = actionSheet.tag;
    if (tag == PushMoreButtonTag) {
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
    } else if (tag == PushUnfollowButtonTag) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self.aoAPICenter postUnfollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
        }
        
    } else if (tag == PushMuteButtonTag) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self.aoAPICenter postMuteForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
        }
        
    } else if (tag == PushBlockingButtonTag) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self.aoAPICenter postBlockForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
        }
        
    } else if (tag == PushSpamButtonTag) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self.aoAPICenter postSpamForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
        }
        
    } else if (tag == PushCancelMuteButtonTag) {
        [self.aoAPICenter postDestroyMuteForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
        
    } else if (tag == PushCancelBlockingButtonTag) {
        [self.aoAPICenter postDestroyBlockForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
    }
    
}

#pragma mark MBPostTweetViewController Delegate
- (void)dismissPostTweetViewController:(MBPostTweetViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendTweetPostTweetViewController:(MBPostTweetViewController *)controller tweetText:(NSString *)tweetText replys:(NSArray *)replys place:(NSDictionary *)place media:(NSArray *)media
{
    [self.aoAPICenter postTweet:tweetText inReplyTo:replys place:place media:media];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

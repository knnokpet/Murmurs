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

#import "MBUser.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"

#import "MBProfileAvatorView.h"
#import "MBProfileDesciptionView.h"

@interface MBDetailUserViewController () <UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _headerImageOffSet;
}

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@property (nonatomic) UIImageView *headerImageView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) MBProfileAvatorView *profileAvatorView;
@property (nonatomic) MBProfileDesciptionView *profileDescriptionView;
@property (nonatomic) UIPageControl *pageControl;

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

- (void)awakeFromNib
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
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
    tableHeaderView.backgroundColor = [UIColor lightGrayColor];
    //self.tableView.tableHeaderView = tableHeaderView;
    
    //CGFloat offset = self.tableView.contentOffset.y;
    _headerImageOffSet = tableHeaderHeight;
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableHeaderHeight)];
    CGRect headerImageFrame = self.headerImageView.frame;
    headerImageFrame.origin.y = _headerImageOffSet;
    self.tableView.tableHeaderView = self.headerImageView;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableHeaderHeight)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.delegate = self;
    NSInteger pageCount = 2;
    [self.scrollView setContentSize:CGSizeMake(pageCount * self.view.frame.size.width, tableHeaderHeight)];
    //[self.view addSubview:self.scrollView];
    [self.headerImageView addSubview:self.scrollView];
    
    self.profileAvatorView = [[MBProfileAvatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableHeaderHeight)];
    self.profileAvatorView.autoresizesSubviews = YES;
    self.profileAvatorView.characterName = self.user.characterName;
    self.profileAvatorView.screenName = self.user.screenName;
    [self.scrollView addSubview:self.profileAvatorView];
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:self.user.userIDStr];
    self.profileAvatorView.avatorImageView.image = avatorImage;
    if (nil == avatorImage) {
        if (nil != self.user && NO == self.user.isDefaultProfileImage) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                [MBImageDownloader downloadBigImageWithURL:self.user.urlHTTPSAtProfileImage completionHandler:^ (UIImage *image, NSData *imageData){
                    if (image) {
                        [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:self.user.userIDStr];
                        CGSize imageSize = CGSizeMake(self.profileAvatorView.avatorImageView.frame.size.width, self.profileAvatorView.avatorImageView.frame.size.height);
                        UIImage *radiusImage = [MBImageApplyer imageForTwitter:image byScallingToFillSize:imageSize radius:8.0f];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.profileAvatorView.avatorImageView.image = radiusImage;
                            [self.profileAvatorView setNeedsLayout];
                        });
                    }
                    
                }failedHandler:^(NSURLResponse *response, NSError *error) {
                    
                }];
            });
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            CGSize imageSize = CGSizeMake(self.profileAvatorView.avatorImageView.frame.size.width, self.profileAvatorView.avatorImageView.frame.size.height);
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:avatorImage byScallingToFillSize:imageSize radius:8.0f];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileAvatorView.avatorImageView.image = radiusImage;
                [self.profileAvatorView setNeedsLayout];
            });
        });
    }
    [self downloadBannerImage];
    
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30);
    self.pageControl.backgroundColor = [UIColor blackColor];
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = NO;
    [self.scrollView addSubview:self.pageControl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureModel];
    [self configureView];
    
    if (self.user.requireLoading) {
        [self.aoAPICenter getUser:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
    } else if (nil != self.userID) {
        [self.aoAPICenter getUser:[self.userID unsignedLongLongValue] screenName:nil];
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
    if (!self.user.urlAtProfileBanner) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [MBImageDownloader downloadBannerImageMobileRetina:self.user.urlAtProfileBanner completionHandler:^ (UIImage *image, NSData *imageData){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headerImageView.image = image;
                //[self.headerImageView setNeedsDisplay];
                //[self.tableView.tableHeaderView addSubview:self.headerImageView];
            });
        }failedHandler:^ (NSURLResponse *response, NSError *error) {
            NSLog(@"image error %@ code %lu", error.description, (unsigned long)error.code);
        }];
    });
}

- (void)pageControll:(id)sender
{
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark Button Action
- (IBAction)didPushFollowButton:(id)sender {
    [self.aoAPICenter postFollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}
- (IBAction)didPushUnfollowButton:(id)sender {
    [self.aoAPICenter postUnfollowForUserID:[self.user.userID unsignedLongLongValue] screenName:self.user.screenName];
}

#pragma mark -
#pragma mark UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfRow = indexPath.row;
    NSString *textLabel;
    NSInteger detailInteger;
    
    switch (numberOfRow) {
        case 0:{
            textLabel = NSLocalizedString(@"All Tweets", nil);
            detailInteger = self.user.tweetCount;
        }
            break;
        case 1: {
            textLabel = NSLocalizedString(@"Following", nil);
            detailInteger = self.user.followsCount;
        }
            break;
        case 2: {
            textLabel = NSLocalizedString(@"Follower", nil);
            detailInteger = self.user.followersCount;
        }
            break;
        case 3: {
            textLabel = NSLocalizedString(@"Favorite", nil);
            detailInteger = self.user.favoritesCount;
        }
            break;
        case 4: {
            textLabel = NSLocalizedString(@"List", nil);
            detailInteger = self.user.listedCount;
        }
            break;
            
        default:
            textLabel = @"";
            detailInteger = 0;
            break;
    }
    cell.textLabel.text = textLabel;
    detailInteger = (0 <= detailInteger) ? detailInteger : 0;
    if (4 != numberOfRow) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", detailInteger];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    switch (index) {
        case 0: {
            MBUserTimelineViewController *userTimelineViewController = [[MBUserTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
            userTimelineViewController.user = self.user;
            [self.navigationController pushViewController:userTimelineViewController animated:YES];
        }
            break;
        case 1: {
            MBFollowingViewController *followingViewController = [[MBFollowingViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
            [followingViewController setUser:self.user];
            [self.navigationController pushViewController:followingViewController animated:YES];
        }
            break;
        case 2: {
            MBFollowerViewController *followerViewController = [[MBFollowerViewController alloc] initWithNibName:@"MBUsersViewController" bundle:nil];
            [followerViewController setUser:self.user];
            [self.navigationController pushViewController:followerViewController animated:YES];
        }
            break;
        case 3: {
            MBFavoritesViewController *favoritesViewController = [[MBFavoritesViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
            [favoritesViewController setUser:self.user];
            [self.navigationController pushViewController:favoritesViewController animated:YES];
        }
            break;
        case 4: {
            MBOtherUserListViewController *otherListViewController = [[MBOtherUserListViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
            [otherListViewController setUser:self.user];
            [self.navigationController pushViewController:otherListViewController animated:YES];
        }
            break;
            
        default:
            break;
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

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users
{
    MBUser *user = [users firstObject];
    [self setUser:user];
    [self.tableView reloadData];
    
    if (nil == self.headerImageView.image && nil != user.urlAtProfileBanner) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadBannerImageMobileRetina:user.urlAtProfileBanner completionHandler:^ (UIImage *image, NSData *imageData){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.headerImageView.image = image;
                    //[self.headerImageView setNeedsDisplay];
                    //[self.tableView.tableHeaderView addSubview:self.headerImageView];
                });
            }failedHandler:^ (NSURLResponse *response, NSError *error) {
                NSLog(@"image error %@ code %lu", error.description, (unsigned long)error.code);
            }];
        });
    }
    if (nil == self.profileAvatorView.avatorImageView.image && nil != user.urlAtProfileImage) {
        ;
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView == scrollView) {
        CGFloat scrollOffset = scrollView.contentOffset.y;
        CGRect scrollViewFrame = self.scrollView.frame;
        
        if (scrollOffset < 0) {
            scrollViewFrame.origin = CGPointMake(0, floorf(scrollOffset / 2.0));
            //self.scrollView.contentOffset = CGPointMake(0, floorf(scrollOffset/* / 2.0*/));
        } else {
            scrollViewFrame.origin = CGPointMake(0, floorf(scrollOffset));
            //self.scrollView.contentOffset = CGPointMake(0, floorf(scrollOffset));
        }
        self.scrollView.frame = scrollViewFrame;
        
    } else if (self.scrollView == scrollView) {
        CGFloat scrollViewWidth = self.scrollView.frame.size.width;
        if ((NSInteger) fmod(self.scrollView.contentOffset.x, scrollViewWidth)) {
            self.pageControl.currentPage = self.scrollView.contentOffset.x / scrollViewWidth;
        }
    }
    
    
}

@end

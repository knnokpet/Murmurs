//
//  MBDetailTweetViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetViewController.h"
#import "MBDetailUserViewController.h"
#import "MBSearchViewController.h"


#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"
#import "MBZoomTransitioning.h"

#import "MBTweetTextComposer.h"
#import "MBTweetManager.h"
#import "MBTweet.h"
#import "MBUser.h"
#import "MBEntity.h"
#import "MBPlace.h"
#import "MBMentionUserLink.h"
#import "MBMediaLink.h"
#import "MBURLLink.h"
#import "MBMentionUserLink.h"
#import "MBHashTagLink.h"

#import "MBMagnifierView.h"
#import "MBMagnifierRangeView.h"
#import "MBTimelineImageContainerView.h"
#import "MBTitleWithImageButton.h"


#import "MBDetailTweetUserTableViewCell.h"
#import "MBDetailTweetTextTableViewCell.h"
#import "MBDetailTweetActionsTableViewCell.h"
#import "MBDetailTweetFavoRetTableViewCell.h"

#define DETAIL_LINE_SPACING 4.0f
#define DETAIL_LINE_HEIGHT 0.0f
#define DETAIL_PARAGRAPF_SPACING 0.0f
#define DETAIL_FONT_SIZE 20.0f

static NSString *countCellIdentifier = @"CountCellIdentifier";
static NSString *userCellIdentifier = @"UserCellIdentifier";
static NSString *tweetCellIdentifier = @"TweetCellIdentifier";
static NSString *retweetCellIdentifier = @"RetweetCellIdentifier";
static NSString *tweetWithImageCellIdentifier = @"TweetWithImageCellIdentifier";
static NSString *retweetWithImageCellIdentifier = @"RetweetWithImageCellIdentifier";
static NSString *actionsCellIdentifier = @"ActionsCellIdentifier";


@interface MBDetailTweetViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSInteger cellsOnCountCell; /* userCell & tweetCell */
}

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) NSMutableArray *replyedTweets;
@property (nonatomic, assign) BOOL fetchsReplyedTweet;/* unused */
@property (nonatomic) NSDictionary *currentUserRetweetedTweet;
@property (nonatomic) MBZoomTransitioning *zoomTransitoining;

@property (nonatomic) MBMagnifierView *magnifierView;
@property (nonatomic) MBMagnifierRangeView *magnifierRangeView;

@end


@implementation MBDetailTweetViewController

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
- (void)setTweet:(MBTweet *)tweet
{
    _tweet = tweet;
}

- (void)setRetweeter:(MBUser *)retweeter
{
    _retweeter = retweeter;
}

#pragma mark -
#pragma mark View
- (void)configureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    
    _replyedTweets = [NSMutableArray array];
    self.fetchsReplyedTweet = NO;
    
    cellsOnCountCell = 2; /* userCell & tweetCell */
}

- (void)configureViews
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    /* remove nonContent's separator */
    UIView *view = [[UIView alloc] init];
    view.backgroundColor  = [UIColor clearColor];
    [self.tableView setTableHeaderView:view];
    [self.tableView setTableFooterView:view];
    
    UINib *userCell = [UINib nibWithNibName:@"MBDetailTweetUserTableViewCell" bundle:nil];
    [self.tableView registerNib:userCell forCellReuseIdentifier:userCellIdentifier];
    UINib *tweetCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
    [self.tableView registerNib:tweetCell forCellReuseIdentifier:tweetCellIdentifier];
    UINib *tweetWithImageCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
    [self.tableView registerNib:tweetWithImageCell forCellReuseIdentifier:tweetWithImageCellIdentifier];
    UINib *retweetCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
    [self.tableView registerNib:retweetCell forCellReuseIdentifier:retweetCellIdentifier];
    UINib *retweetWithImageCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
    [self.tableView registerNib:retweetWithImageCell forCellReuseIdentifier:retweetWithImageCellIdentifier];
    //UINib *countCell = [UINib nibWithNibName:@"MBDetailTweetFavoRetTableViewCell" bundle:nil];
    //[self.tableView registerNib:countCell forCellReuseIdentifier:countCellIdentifier];
    UINib *actionsCell = [UINib nibWithNibName:@"MBDetailTweetActionsTableViewCell" bundle:nil];
    [self.tableView registerNib:actionsCell forCellReuseIdentifier:actionsCellIdentifier];
    
    self.magnifierView = [[MBMagnifierView alloc] init];
    self.magnifierRangeView = [[MBMagnifierRangeView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Tweet", nil);
    
    [self configureModel];
    [self configureViews];
    
    if (self.tweet.requireLoading || self.tweet.isRetweeted) {
        [self.aoAPICenter getTweet:[self.tweet.tweetID unsignedLongLongValue]];
    }
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
/* un used, because low performance for API. And there is not API for the behavior */
/* stream API でとろう */
- (void)fetchTweetInReply:(MBTweet *)tweet
{
    if (tweet.tweetIDStrOfOriginInReply || tweet.tweetIDOfOriginInReply) {
        NSString *key = tweet.tweetIDStrOfOriginInReply;
        if (!key) {
            key = [tweet.tweetIDOfOriginInReply stringValue];
        }
        
        MBTweet *replyedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:key];
        if (replyedTweet) {
            [self fetchTweetInReply:replyedTweet];
        } else {
            NSNumber *replyedTweetID = tweet.tweetIDOfOriginInReply;
            if (!replyedTweetID) {
                replyedTweetID = [[[NSNumberFormatter alloc] init] numberFromString:tweet.tweetIDStrOfOriginInReply];
            }
            
            self.fetchsReplyedTweet = YES;
            [self.aoAPICenter getTweet:[replyedTweetID unsignedLongLongValue]];
        }
    } else {
        self.fetchsReplyedTweet = NO;
    }
}

#pragma mark Button Action
- (IBAction)didPushScreenNameButton:(id)sender {
    MBUser *selectedUser = self.tweet.tweetUser;
    MBDetailUserViewController *userViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
    [userViewController setUser:selectedUser];
    [self.navigationController pushViewController:userViewController animated:YES];
}

- (IBAction)didPushReplyButton:(id)sender {
    MBPostTweetViewController *postTweetViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postTweetViewController.delegate = self;
    [postTweetViewController addReply:self.tweet.tweetID];
    [postTweetViewController setReferencedTweet:self.tweet];
    [postTweetViewController setScreenName:self.tweet.tweetUser.screenName];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postTweetViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}
- (IBAction)didPushRetweetButton:(id)sender {
    UIActionSheet *retweetActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Retweet", @"Retweet with Coment", nil];
    [retweetActionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)didPushRetweetWithComentButton:(id)sender
{
    MBPostTweetViewController *postTweetViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postTweetViewController.delegate = self;
    [postTweetViewController setRetweetWithComent:self.tweet.tweetText tweetedUser:self.tweet.tweetUser.screenName];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postTweetViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushCancelRetweetButton
{
    UIActionSheet *retweetActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Retweet" otherButtonTitles:nil];
    [retweetActionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)didPushFavoriteButton:(id)sender {
    [self.aoAPICenter postFavoriteForTweetID:[self.tweet.tweetID unsignedLongLongValue]];
}
- (IBAction)didPushCancelFavoriteButton:(id)sender {
    [self.aoAPICenter postDestroyFavoriteForTweetID:[self.tweet.tweetID unsignedLongLongValue]];
}

- (void)didPushTweetButton
{
    NSString *tweetURLString = [NSString stringWithFormat:@"https://twitter.com/%@/status/%lld", self.tweet.tweetUser.screenName, [self.tweet.tweetID unsignedLongLongValue]];
    NSURL *url = [NSURL URLWithString:tweetURLString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    MBWebBrowsViewController *webViewController = [[MBWebBrowsViewController alloc] init];
    [webViewController setUrlRequest:urlRequest];
    webViewController.delegate = self;
    UINavigationController *webNavigation = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self.navigationController presentViewController:webNavigation animated:YES completion:nil];
}

#pragma mark -
#pragma mark Delegate
#pragma mark TableView Delegate Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    CGFloat verticalMargin = 10.0f;
    CGFloat horizontalMargin = 16.0f;
    CGFloat imageMargin = 8.0f;
    CGFloat dateMargin = 8.0f;
    CGFloat dateRetweetViewHeight = 20.0f;
    CGFloat marginBetweenDateRetweeter = 10.0f;
    CGFloat verticalMarginRetweeter = 2.0f;
    
    NSInteger actionsRow = cellsOnCountCell;
    if (self.tweet.retweetedCount > 0 || self.tweet.favoritedCount > 0) {
        actionsRow += 1;
    }
    
    if (0 == indexPath.row) {
        height = 48.0f + (verticalMargin * 2);
    } else if (1 == indexPath.row) {
        
        NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
        
        NSInteger viewWidth = self.tableView.bounds.size.width - (horizontalMargin * 2);
        CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(viewWidth, CGFLOAT_MAX) lineSpace:DETAIL_LINE_SPACING font:[UIFont systemFontOfSize:DETAIL_FONT_SIZE]];
        height = textRect.size.height + dateRetweetViewHeight + verticalMargin;
        
        CGFloat addingHeight = 0.0f;
        if (self.retweeter && self.tweet.entity.media.count > 0) {
            addingHeight = 160.0f + imageMargin * 2 + dateRetweetViewHeight + verticalMarginRetweeter + marginBetweenDateRetweeter;
        } else if (self.tweet.entity.media.count > 0) {
            addingHeight = 160.0f + imageMargin * 2 + verticalMargin;
        } else if (self.retweeter) {
            addingHeight = dateMargin + dateRetweetViewHeight + verticalMarginRetweeter + marginBetweenDateRetweeter;
        } else {
            addingHeight = dateMargin + verticalMargin;
        }

        height += addingHeight;
    }else if (indexPath.row == actionsRow) {
        height = 56.0f;
    }else {
        height = 32.0f;
    }
    
    
    
    return  height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger defaultRows = 3;
    if (self.tweet.retweetedCount > 0 || self.tweet.favoritedCount > 0) {
        defaultRows += 1;
    }
    return defaultRows;
}

- (NSIndexPath *)lastIndexPath
{
    NSInteger sectionAmount = [self.tableView numberOfSections];
    NSInteger rowsForIndexPath = [self.tableView numberOfRowsInSection:sectionAmount - 1];
    NSIndexPath *lastIndexpath = [NSIndexPath indexPathForRow:rowsForIndexPath - 1 inSection:sectionAmount - 1];
    
    return lastIndexpath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    
    UITableViewCell *cell;
    if (0 == indexPath.row) {
        MBDetailTweetUserTableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:userCellIdentifier];
        [self updateUserCell:userCell];
        cell = userCell;
    } else if (1 == indexPath.row) {
        
        MBDetailTweetTextTableViewCell *textCell;
        if (self.tweet.entity.media.count > 0 && (self.retweeter || self.tweet.isRetweeted)) {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:retweetWithImageCellIdentifier];
        } else if (self.tweet.entity.media.count > 0) {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetWithImageCellIdentifier];
            [textCell removeRetweetView];
        } else if (self.retweeter || self.tweet.isRetweeted) {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:retweetCellIdentifier];
            [textCell removeImageContainerView];
        }
        else {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
            [textCell removeImageContainerView];
            [textCell removeRetweetView];
        }
        [self updateTweetViewCell:textCell];
        cell = textCell;
    } else if (lastIndexPath.row == indexPath.row) {
        MBDetailTweetActionsTableViewCell *actionsCell = [self.tableView dequeueReusableCellWithIdentifier:actionsCellIdentifier];
        [self updateActionsCell:actionsCell];
        cell = actionsCell;
    }else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:countCellIdentifier];
        if (!cell) {
            cell = [[MBDetailTweetFavoRetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:countCellIdentifier];
        }
        [self updateCountCell:(MBDetailTweetFavoRetTableViewCell *)cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)updateUserCell:(MBDetailTweetUserTableViewCell *)cell
{
    MBUser *user = self.tweet.tweetUser;
    cell.characterNameLabel.text = user.characterName;
    [cell setScreenName:user.screenName];
    [cell setIsVerified:user.isVerified];
    [cell.twitterButton addTarget:self action:@selector(didPushTweetButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedTimelineImageForUser:user.userIDStr];
    if (!avatorImage) {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(globalQueue, ^{
            [MBImageDownloader downloadOriginImageWithURL:user.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:user.userIDStr];
                    CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:cell.avatorImageView.layer.cornerRadius];
                    [[MBImageCacher sharedInstance] storeTimelineImage:image forUserID:user.userIDStr];
                    
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

- (void)updateTweetViewCell:(MBDetailTweetTextTableViewCell *)cell
{
    
    cell.tweetTextView.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
    cell.tweetTextView.lineSpace = DETAIL_LINE_SPACING;
    cell.tweetTextView.lineHeight = DETAIL_LINE_HEIGHT;
    cell.tweetTextView.paragraphSpace = DETAIL_PARAGRAPF_SPACING;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
    //cell.tweetTextView.isSelectable = YES; ルーペを実装できないため。
    cell.tweetTextView.delegate = self;
    
    // date
    // parse 時に strp で locale を計算した createDate を作成しているので。
    NSCalendar *calendaar = [NSCalendar currentCalendar];
    NSTimeZone *currentTimezone = calendaar.timeZone;
    NSDateComponents *components = [calendaar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:self.tweet.createdDate];
    
    NSInteger second = [currentTimezone secondsFromGMT];
    long hour = second / (60 * 60);
    if (hour < 1) {
        long minute = second / 60;
        [components setMinute:components.minute - minute];
    } else {
        [components setHour:components.hour - hour];
        if (components.hour < 0) {
            [components setDay:components.day - 1];
            [components setHour:24 + components.hour];
        }
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%ld/%02ld/%02ld %02ld:%02ld", [[NSNumber numberWithInteger: components.year] longValue], [[NSNumber numberWithInteger:components.month] longValue], [[NSNumber numberWithInteger: components.day] longValue], [[NSNumber numberWithInteger: components.hour] longValue],[[NSNumber numberWithInteger: components.minute] longValue]];
    
    cell.dateView.attributedString = [MBTweetTextComposer attributedStringForDetailTweetDate:dateString font:[UIFont systemFontOfSize:14.0f] screeName:self.tweet.tweetUser.screenName tweetID:[self.tweet.tweetID unsignedLongLongValue]];
    cell.dateView.delegate = self;
    
    if (self.tweet.place) {
        NSString *placeName = [NSString stringWithFormat:@"From %@", self.tweet.place.countryFullName];
        cell.geoLabel.text = placeName;
    } else {
        [cell.geoLabel removeFromSuperview];
    }
    
    // retweet
    if (!self.retweeter) {
        [cell removeRetweetView];
    } else {
        cell.retweeterView.retweeterString  = [MBTweetTextComposer attributedStringForTimelineRetweeter:self.retweeter font:[UIFont systemFontOfSize:14.0f]];
        cell.retweeterView.delegate = self;
        NSAttributedString *retweeterName = [MBTweetTextComposer attributedStringForTimelineRetweeter:self.retweeter font:[UIFont systemFontOfSize:15.0f]];
        if ([[MBAccountManager sharedInstance].currentAccount.userID isEqualToString:self.retweeter.userIDStr]) {
            retweeterName = [MBTweetTextComposer attributedStringByRetweetedMeForTimelineWithfont:[UIFont systemFontOfSize:15.0f]];
        }
        [cell.retweeterView setRetweeterString:retweeterName];
        [cell.retweeterView setUserLink:[[MBMentionUserLink alloc]initWithUserID:self.retweeter.userID IDStr:self.retweeter.userIDStr screenName:self.retweeter.screenName]];
        cell.retweeterView.delegate = self;
        
    }
    
    // separatorInsets
    UIEdgeInsets separatorInsets = cell.separatorInset;
    separatorInsets.left = 15.0f;
    if (self.tweet.favoritedCount > 0 || self.tweet.retweetedCount > 0) {
        separatorInsets.left = self.view.bounds.size.width;
    }
    cell.separatorInset = separatorInsets;
    
    // mediaImage
    NSInteger imageCounts = self.tweet.entity.media.count;
    if (imageCounts > 0) {
        cell.imageContainerView.imageCount = imageCounts;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            int i = 0;
            for (MBMediaLink *mediaLink in self.tweet.entity.media) {
                UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:mediaLink.mediaIDStr];
                MBMediaImageView *mediaImageView = [cell.imageContainerView.imageViews objectAtIndex:i];
                mediaImageView.delegate = self;
                mediaImageView.mediaIDStr = mediaLink.mediaIDStr;
                mediaImageView.mediaHTTPURLString = mediaLink.originalURLHttpsText;
                
                if (mediaImage) {
                    CGSize mediaImageSize = CGSizeMake(mediaImageView.frame.size.width, mediaImageView.frame.size.height);
                    UIImage *croppedImage = [MBImageApplyer imageForMediaWithImage:mediaImage size:mediaImageSize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        mediaImageView.mediaImage = croppedImage;
                    });
                    
                } else {
                    
                    [MBImageDownloader downloadMediaImageWithURL:mediaLink.originalURLHttpsText completionHandler:^(UIImage *image, NSData *imageData) {
                        if (image) {
                            [[MBImageCacher sharedInstance] storeMediaImage:image data:imageData forMediaID:mediaLink.mediaIDStr];
                            CGSize mediaImageSize = CGSizeMake(mediaImageView.frame.size.width, mediaImageView.frame.size.height);
                            UIImage *croppedImage = [MBImageApplyer imageForMediaWithImage:image size:mediaImageSize];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [mediaImageView setMediaImage:croppedImage];
                            });
                        }
                        
                    } failedHandler:^(NSURLResponse *response, NSError *error) {
                        
                    }];
                }
            }
        });
    }
}

- (void)updateCountCell:(MBDetailTweetFavoRetTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL requireRetweet = NO;
    BOOL requireFavorite = NO;
    NSString *retCountStr = nil;
    NSString *favoCountStr = nil;
    if (self.tweet.favoritedCount > 0 && self.tweet.retweetedCount > 0) {
        requireRetweet = requireFavorite = YES;
        retCountStr = [NSString stringWithFormat:@"%ld", (long)self.tweet.retweetedCount];
        favoCountStr = [NSString stringWithFormat:@"%ld", (long)self.tweet.favoritedCount];
        
    } else if (self.tweet.favoritedCount > 0) {
        requireFavorite = YES;
        favoCountStr = [NSString stringWithFormat:@"%ld", (long)self.tweet.favoritedCount];
        
    } else if (self.tweet.retweetedCount > 0) {
        requireRetweet = YES;
        retCountStr = [NSString stringWithFormat:@"%ld", (long)self.tweet.retweetedCount];
    }
    [cell setRetweetCountStr:retCountStr];
    [cell setFavoriteCountStr:favoCountStr];
    [cell setRequireRetweet:requireRetweet];
    [cell setRequireFavorite:requireFavorite];
    
    
    
    if (self.tweet.isFavorited) {
        [cell setFavoriteImage:[UIImage imageNamed:@"Star-Orange"]];
        [cell.favoriteButton addTarget:self action:@selector(didPushCancelFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell setFavoriteImage:[UIImage imageNamed:@"Star-Line"]];
        [cell.favoriteButton addTarget:self action:@selector(didPushFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.tweet.isRetweeted) {
        [cell setRetweetImage:[UIImage imageNamed:@"Retweet-Green"]];
        [cell.retweetButton addTarget:self action:@selector(didPushCancelRetweetButton) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell setRetweetImage:[UIImage imageNamed:@"Retweet-Line"]];
        [cell.retweetButton addTarget:self action:@selector(didPushRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)updateActionsCell:(MBDetailTweetActionsTableViewCell *)cell
{
    [cell.replyButton setButtonTitle:NSLocalizedString(@"Reply", nil)];
    [cell.replyButton setButtonImage:[UIImage imageNamed:@"reply-TintBlue"]];
    [cell.replyButton addTarget:self action:@selector(didPushReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // retweet
    if (self.tweet.isRetweeted) {
        [cell.retweetButton setButtonTitle:NSLocalizedString(@"Cancel Retweet", nil)];
        [cell.retweetButton setButtonImage:[UIImage imageNamed:@"Retweet-Cacncel-TintBlue"]];
        [cell.retweetButton removeTarget:self action:@selector(didPushRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.retweetButton addTarget:self action:@selector(didPushCancelRetweetButton) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.retweetButton setButtonTitle:NSLocalizedString(@"Retweet", nil)];
        [cell.retweetButton setButtonImage:[UIImage imageNamed:@"Retweet-TintBlue"]];
        [cell.retweetButton removeTarget:self action:@selector(didPushCancelRetweetButton) forControlEvents:UIControlEventTouchUpInside];
        [cell.retweetButton addTarget:self action:@selector(didPushRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    MBAccount *selectedAccount = [[MBAccountManager sharedInstance] currentAccount];
    if ([self.tweet.tweetUser.userIDStr isEqualToString:selectedAccount.userID] || self.tweet.tweetUser.isProtected) {
        [cell.retweetButton setEnabled:NO];
    }
    
    
    // favorite
    if (self.tweet.isFavorited) {
        [cell.favoriteButton setButtonTitle:NSLocalizedString(@"Cancel Favorite", nil)];
        [cell.favoriteButton setButtonImage:[UIImage imageNamed:@"Star-Cancel-TintBlue"]];
        [cell.favoriteButton addTarget:self action:@selector(didPushCancelFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.favoriteButton setButtonTitle:NSLocalizedString(@"Favorite", nil)];
        [cell.favoriteButton setButtonImage:[UIImage imageNamed:@"Star-TintBlue"]];
        [cell.favoriteButton addTarget:self action:@selector(didPushFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (0 == indexPath.row) {
        MBUser *selectedUser = self.tweet.tweetUser;
        MBDetailUserViewController *userViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
        [userViewController setUser:selectedUser];
        [self.navigationController pushViewController:userViewController animated:YES];
    }
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == actionSheet.destructiveButtonIndex){
        NSDictionary *userRetweetedTweet = self.tweet.currentUserRetweetedTweet;
        NSNumber *retweetID = [userRetweetedTweet numberForKey:@"id"];
        if (!retweetID) {
            retweetID = [self.currentUserRetweetedTweet objectForKey:@"id"];
        }
        
        
        [self.aoAPICenter postDestroyTweetForTweetID:[retweetID unsignedLongLongValue]];
    } else if (buttonIndex == 0) { // Retweet
        [self.aoAPICenter postRetweetForTweetID:[self.tweet.tweetID unsignedLongLongValue]];
    } else if (buttonIndex == 1) { // Retweet with Coment
        
    }
}

#pragma mark PostTweetViewController Delegate
- (void)dismissPostTweetViewController:(MBPostTweetViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

- (void)sendTweetPostTweetViewController:(MBPostTweetViewController *)controller tweetText:(NSString *)tweetText replys:(NSArray *)replys place:(NSDictionary *)place media:(NSArray *)media
{
    [self.aoAPICenter postTweet:tweetText inReplyTo:replys place:place media:media];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark WebBrowsViewController Delegate
- (void)closeBrowsViewController:(MBWebBrowsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark AOuth_APICenterDelegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets
{
    NSLog(@"requesttype = %d", requestType);
    MBTweet *tweet = [tweets firstObject];
    if (!tweet) {
        return;
    }
    
    if (requestType == MBTwitterStatusesShowSingleTweetRequest) {
        [self setTweet:tweet];
        [self.tableView reloadData];
        
    } else if (requestType == MBTwitterStatusesRetweetsOfTweetRequest) {
        if (!self.retweeter || [[[[MBAccountManager sharedInstance] currentAccount] userID] isEqualToString:self.retweeter.userIDStr] == NO ) {
            self.retweeter = [[MBUserManager sharedInstance] storedUserForKey:[[[MBAccountManager sharedInstance] currentAccount] userID]];
        }
        self.currentUserRetweetedTweet = @{@"id": tweet.tweetID};
        [self.tweet setIsRetweeted:YES];
        self.tweet.retweetedCount = self.tweet.retweetedCount + 1;
        [self.tableView reloadData];
        
    } else if (requestType == MBTwitterStatusesDestroyTweetRequest) {
        if ([[[[MBAccountManager sharedInstance] currentAccount] userID] isEqualToString:self.retweeter.userIDStr] == YES) {
            self.retweeter = nil;
        }
        [self.tweet setIsRetweeted:NO];
        self.tweet.retweetedCount = self.tweet.retweetedCount - 1;
        [self.tableView reloadData];
        
    } else if (requestType == MBTwitterFavoritesCreateRequest) {
        [self setTweet:tweet];
        [self.tableView reloadData];
        
    } else if (requestType == MBTwitterFavoritesDestroyRequest) {
        [self setTweet:tweet];
        [self.tableView reloadData];
        
    } else if (requestType == MBTwitterStatusesUpdateRequest) {
        
    }
    
}

#pragma mark MBMediaImageView Delegate
- (void)didTapImageView:(MBMediaImageView *)imageView mediaIDStr:(NSString *)mediaIDStr urlString:(NSString *)urlString touchedPoint:(CGPoint)touchedPoint rect:(CGRect)rect
{
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    CGPoint convertedPointToSelfView = [self.view convertPoint:center fromView:imageView];
    
    MBTweet *selectedTweet = self.tweet;
    
    MBImageViewController *imageViewController = [[MBImageViewController alloc] init];
    [imageViewController setTweet:selectedTweet];
    imageViewController.delegate = self;
    imageViewController.transitioningDelegate = self;
    self.zoomTransitoining = [[MBZoomTransitioning alloc] initWithPoint:convertedPointToSelfView];
    
    UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:mediaIDStr];
    imageViewController.mediaImage = mediaImage;
    if (!mediaImage) {
        [imageViewController setMediaIDStr:mediaIDStr];
        [imageViewController setImageURLString:urlString];
    }
    
    [self presentViewController:imageViewController animated:YES completion:nil];
}

#pragma mark TweetTextViewDelegate
- (void)tweetTextView:(MBTweetTextView *)textView clickOnLink:(MBLinkText *)linktext point:(CGPoint)touchePoint
{
    CGPoint convertedPointToSelfView = [self.view convertPoint:touchePoint fromView:textView];
    
    if ([linktext.obj isKindOfClass:[MBURLLink class]]) {
        MBURLLink *URLLink = (MBURLLink *)linktext.obj;
        NSString *expandedURLText = URLLink.expandedURLText;
        if ([expandedURLText hasPrefix:@"http"]) {
            NSURL *url = [NSURL URLWithString:expandedURLText];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            MBWebBrowsViewController *browsViewController = [[MBWebBrowsViewController alloc] init];
            [browsViewController setUrlRequest:request];
            browsViewController.delegate = self;
            UINavigationController *webNavigation = [[UINavigationController alloc] initWithRootViewController:browsViewController];
            [self.navigationController presentViewController:webNavigation animated:YES completion:nil];
        }
    } else if ([linktext.obj isKindOfClass:[MBMentionUserLink class]]) {
        MBMentionUserLink *mentionLink = (MBMentionUserLink *)linktext.obj;
        NSString *userIDStr = mentionLink.userIDStr;
        
        MBUser *selectedUser = [[MBUserManager sharedInstance] storedUserForKey:userIDStr];
        MBDetailUserViewController *userViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
        [userViewController setUser:selectedUser];
        if (nil == selectedUser) {
            NSNumber *userID = mentionLink.userID;
            [userViewController setUserID:userID];
        }
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if ([linktext.obj isKindOfClass:[MBHashTagLink class]]) {
        MBHashTagLink *hashtagLink = (MBHashTagLink *)linktext.obj;
        MBSearchViewController *searchViewController = [[MBSearchViewController alloc] init];
        [searchViewController setSearchingTweetQuery:[NSString stringWithFormat:@"#%@", hashtagLink.displayText]];
        [self.navigationController pushViewController:searchViewController animated:YES];
        
    } else if ([linktext.obj isKindOfClass:[MBMediaLink class]]) {
        
        MBMediaLink *link = linktext.obj;
        
        MBImageViewController *imageViewController = [[MBImageViewController alloc] init];
        [imageViewController setImageURLString:link.originalURLHttpsText];
        [imageViewController setMediaIDStr:link.mediaIDStr];
        [imageViewController setTweet:self.tweet];
        imageViewController.delegate = self;
        UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:link.mediaIDStr];
        imageViewController.mediaImage = mediaImage;
        
        imageViewController.transitioningDelegate = self;
        
        self.zoomTransitoining = [[MBZoomTransitioning alloc] initWithPoint:convertedPointToSelfView];
        [self presentViewController:imageViewController animated:YES completion:nil];
    }
}

- (void)tweetTextViewShowMagnifier:(MBTweetTextView *)textView point:(CGPoint)point
{
    if (!self.magnifierView.superview) {
        [self.magnifierView showInView:self.view.window forView:self.view atPoint:[self.view convertPoint:point fromView:textView]];
    }
    [self.magnifierView moveToPoint:[self.view convertPoint:point fromView:textView]];
}

- (void)tweetTextViewHideMagnifier:(MBTweetTextView *)textView
{
    [self.magnifierView hide];
}

- (void)tweetTextViewShowMagnifierRange:(MBTweetTextView *)textView point:(CGPoint)point
{
    if (!self.magnifierRangeView.superview) {
        [self.magnifierRangeView showInView:self.view.window forView:self.view atPoint:[self.view convertPoint:point fromView:textView]];
    }
    [self.magnifierRangeView moveToPoint:[self.view convertPoint:point fromView:textView]];
}

- (void)tweetTextViewHideMagnifierRange:(MBTweetTextView *)textView
{
    [self.magnifierRangeView hideView];
}

#pragma mark RetweetView Delegate
- (void)retweetView:(MBRetweetView *)retweetView userLink:(MBMentionUserLink *)userLink
{
    MBUser *selectedUser = [[MBUserManager sharedInstance] storedUserForKey:userLink.userIDStr];
    MBDetailUserViewController *userViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
    [userViewController setUser:selectedUser];
    if (nil == selectedUser) {
        NSNumber *userID = userLink.userID;
        [userViewController setUserID:userID];
    }
    [self.navigationController pushViewController:userViewController animated:YES];
}

#pragma mark ImageViewController Delegate
- (void)dismissImageViewController:(MBImageViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Transitioning Delegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.zoomTransitoining;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.zoomTransitoining.isReverse = YES;
    return self.zoomTransitoining;
}

@end

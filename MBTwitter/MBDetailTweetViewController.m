//
//  MBDetailTweetViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetViewController.h"
#import "MBDetailUserViewController.h"



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

#define LINE_SPACING 4.0f
#define LINE_HEIGHT 0.0f
#define PARAGRAPF_SPACING 0.0f
#define FONT_SIZE 20.0f

static NSString *countCellIdentifier = @"CountCellIdentifier";
static NSString *userCellIdentifier = @"UserCellIdentifier";
static NSString *tweetCellIdentifier = @"TweetCellIdentifier";
static NSString *tweetFavoriteIdentifier = @"FavoriteCellIdentifier";
static NSString *tweetWithImageCellIdentifier = @"TweetWithImageCellIdentifier";
static NSString *tweetFavoriteWithImageCellIdentifier = @"FavoriteWithImageCellIdentifier";
static NSString *actionsCellIdentifier = @"ActionsCellIdentifier";

static NSString *countKey = @"CountKey";
static NSString *contentKey = @"ContentKey";
static NSString *contentIdentifier = @"ContentIdentifier";
static NSString *favoriteStr = @"fav";
static NSString *retweetStr = @"ret";

@interface MBDetailTweetViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSInteger cellsOnCountCell;
}

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) NSMutableArray *expandingDataSource;
@property (nonatomic, readonly) NSMutableArray *replyedTweets;
@property (nonatomic, assign) BOOL fetchsReplyedTweet;/* unused */
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
    
    _expandingDataSource = [NSMutableArray array];
    if (tweet.favoritedCount > 0) {
        NSDictionary *favoritDict = @{countKey: [NSNumber numberWithInteger:tweet.favoritedCount], contentKey: NSLocalizedString(@"Favorite", nil), contentIdentifier: favoriteStr};
        [self.expandingDataSource addObject:favoritDict];
    }
    if (tweet.retweetedCount > 0) {
        NSDictionary *retweetDict = @{countKey: [NSNumber numberWithInteger:tweet.retweetedCount], contentKey: NSLocalizedString(@"Retweet", nil), contentIdentifier: retweetStr};
        [self.expandingDataSource addObject:retweetDict];
    }
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
    UINib *tweetFavoriteCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
    [self.tableView registerNib:tweetFavoriteCell forCellReuseIdentifier:tweetFavoriteIdentifier];
    UINib *tweetWithImageCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
    [self.tableView registerNib:tweetWithImageCell forCellReuseIdentifier:tweetWithImageCellIdentifier];
    UINib *tweetFavoriteWithImageCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
    [self.tableView registerNib:tweetFavoriteWithImageCell forCellReuseIdentifier:tweetFavoriteWithImageCellIdentifier];
    UINib *actionsCell = [UINib nibWithNibName:@"MBDetailTweetActionsTableViewCell" bundle:nil];
    [self.tableView registerNib:actionsCell forCellReuseIdentifier:actionsCellIdentifier];
    
    self.magnifierView = [[MBMagnifierView alloc] init];
    self.magnifierRangeView = [[MBMagnifierRangeView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    UIActionSheet *retweetActionSheet;
    if (NO == self.tweet.isRetweeted) {
        retweetActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Retweet", @"Retweet with Coment", nil];
    } else {
        retweetActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Retweet" otherButtonTitles:nil];
    }
    
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
    if (self.tweet.currentUserRetweetedTweet) {
        NSNumber *tweetID = [self.tweet.currentUserRetweetedTweet numberForKey:@"id"];
        [self.aoAPICenter postDestroyTweetForTweetID:[tweetID unsignedLongLongValue]];
    } else {
        // つぶやきオブジェクトを読み込んでももう一度メソッド実行させることが出来ないなぁ。
        // まぁ、この時点でつぶやきオブジェクトが無かったらそれはそれで問題なんだけど。
        [self.aoAPICenter getTweet:[self.tweet.tweetID unsignedLongLongValue]];
    }
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
    CGFloat innnerVerticalMargin = 4.0f;
    CGFloat imageMargin = 8.0f;
    CGFloat dateMargin = 8.0f;
    CGFloat dateRetweetViewHeight = 20.0f;
    
    NSInteger actionsRow = 2 + self.expandingDataSource.count;
    if (0 == indexPath.row) {
        height = 48.0f + (verticalMargin * 2);
    } else if (1 == indexPath.row) {
        
        NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
        
        NSInteger viewWidth = self.tableView.bounds.size.width - (horizontalMargin * 2);
        CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(viewWidth, CGFLOAT_MAX) lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:FONT_SIZE]];
        height = textRect.size.height + dateRetweetViewHeight + verticalMargin;
        
        CGFloat addingHeight = 0.0f;
        if (self.retweeter && self.tweet.entity.media.count > 0) {
            addingHeight = 160.0f + imageMargin * 2 + dateRetweetViewHeight + innnerVerticalMargin + 2.0f;
        } else if (self.tweet.entity.media.count > 0) {
            addingHeight = 160.0f + imageMargin * 2 + verticalMargin;
        } else if (self.retweeter) {
            addingHeight = dateMargin + dateRetweetViewHeight + innnerVerticalMargin + 2.0f;
        } else {
            addingHeight = dateMargin + verticalMargin;
        }

        height += addingHeight;
    } else if (indexPath.row == actionsRow) {
        height = 56.0f;
    }else {
        ;
    }
    
    
    
    return  height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3 + [self.expandingDataSource count];
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
        if (self.tweet.entity.media.count > 0 && self.tweet.isFavorited) {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetFavoriteWithImageCellIdentifier];
        } else if (self.tweet.entity.media.count > 0) {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetWithImageCellIdentifier];
            [textCell removeFavoriteView];
        } else if (self.tweet.isFavorited) {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetFavoriteIdentifier];
            [textCell removeImageContainerView];
        }
        else {
            textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
            [textCell removeImageContainerView];
            [textCell removeFavoriteView];
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:countCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [self updateCountCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)updateUserCell:(MBDetailTweetUserTableViewCell *)cell
{
    MBUser *user = self.tweet.tweetUser;
    cell.characterNameLabel.text = user.characterName;
    [cell setScreenName:user.screenName];
    [cell.twitterButton addTarget:self action:@selector(didPushTweetButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedTimelineImageForUser:user.userIDStr];
    if (!avatorImage) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultImage@2x" ofType:@"png"];
        UIImage *defaultImage = [[UIImage alloc] initWithContentsOfFile:path];
        
        avatorImage = defaultImage;
        if (NO == user.isDefaultProfileImage) {
            
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
            
        }
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
    
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.tweetTextView.lineSpace = LINE_SPACING;
    cell.tweetTextView.lineHeight = LINE_HEIGHT;
    cell.tweetTextView.paragraphSpace = PARAGRAPF_SPACING;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
    //cell.tweetTextView.isSelectable = YES; ルーペを実装できないため。
    cell.tweetTextView.delegate = self;
    
    // date
    // parse 時に strp で locale を計算した createDate を作成しているので。
    NSCalendar *calendaar = [NSCalendar currentCalendar];
    NSTimeZone *currentTimezone = calendaar.timeZone;
    NSDateComponents *components = [calendaar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:self.tweet.createdDate];
    
    NSInteger second = [currentTimezone secondsFromGMT];
    int hour = second / (60 * 60);
    if (hour < 1) {
        int minute = second / 60;
        [components setMinute:components.minute - minute];
    } else {
        [components setHour:components.hour - hour];
        if (components.hour < 0) {
            [components setDay:components.day - 1];
            [components setHour:24 + components.hour];
        }
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%d/%02d/%02d %02d:%02d", components.year, components.month, components.day, components.hour, components.minute];
    
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
        cell.retweetView.attributedString  = [MBTweetTextComposer attributedStringForTimelineRetweeter:self.retweeter font:[UIFont systemFontOfSize:14.0f]];
        cell.retweetView.delegate = self;
        NSAttributedString *retweeterName = [MBTweetTextComposer attributedStringForTimelineRetweeter:self.retweeter font:[UIFont systemFontOfSize:15.0f]];
        if ([[MBAccountManager sharedInstance].currentAccount.userID isEqualToString:self.retweeter.userIDStr]) {
            retweeterName = [MBTweetTextComposer attributedStringByRetweetedMeForTimelineWithfont:[UIFont systemFontOfSize:15.0f]];
        }
        [cell.retweeterView setRetweeterString:retweeterName];
        [cell.retweeterView setUserLink:[[MBMentionUserLink alloc]initWithUserID:self.retweeter.userID IDStr:self.retweeter.userIDStr screenName:self.retweeter.screenName]];
        cell.retweeterView.delegate = self;
    }
    
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
                        
                        mediaImageView.image = croppedImage;
                    });
                    
                } else {
                    
                    [MBImageDownloader downloadMediaImageWithURL:mediaLink.originalURLHttpsText completionHandler:^(UIImage *image, NSData *imageData) {
                        if (image) {
                            [[MBImageCacher sharedInstance] storeMediaImage:image data:imageData forMediaID:mediaLink.mediaIDStr];
                            CGSize mediaImageSize = CGSizeMake(mediaImageView.frame.size.width, mediaImageView.frame.size.height);
                            UIImage *croppedImage = [MBImageApplyer imageForMediaWithImage:image size:mediaImageSize];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [mediaImageView setImage:croppedImage];
                            });
                        }
                        
                    } failedHandler:^(NSURLResponse *response, NSError *error) {
                        
                    }];
                }
            }
        });
    }
}

- (void)updateCountCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger expandedIndex = indexPath.row - cellsOnCountCell;
    if (self.expandingDataSource.count - 1 < expandedIndex) {
        return;
    }
    
    NSDictionary *countDict = [self.expandingDataSource objectAtIndex:expandedIndex];
    NSNumber *count = [countDict objectForKey:countKey];
    NSString *contentStr = [countDict objectForKey:contentKey];
    
    cell.textLabel.text = contentStr;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)count.integerValue];
}

- (void)updateActionsCell:(MBDetailTweetActionsTableViewCell *)cell
{
    [cell.replyButton setButtonTitle:NSLocalizedString(@"Reply", nil)];
    [cell.replyButton setButtonImage:[UIImage imageNamed:@"reply-Cell-Boarder-Tint"]];
    [cell.replyButton addTarget:self action:@selector(didPushReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // retweet
    if (self.tweet.isRetweeted) {
        [cell.retweetButton setButtonTitle:NSLocalizedString(@"Cancel", nil)];
        [cell.retweetButton setButtonImage:[UIImage imageNamed:@"retweet-Boarder-Tint"]];
        [cell.retweetButton addTarget:self action:@selector(didPushRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.retweetButton setButtonTitle:NSLocalizedString(@"Retweet", nil)];
        [cell.retweetButton setButtonImage:[UIImage imageNamed:@"retweet-Boarder-Tint"]];
        [cell.retweetButton addTarget:self action:@selector(didPushRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // favorite
    if (self.tweet.isFavorited) {
        [cell.favoriteButton setButtonTitle:NSLocalizedString(@"Cancel", nil)];
        [cell.favoriteButton setButtonImage:[UIImage imageNamed:@"Star-Boarder-Tint"]];
        [cell.favoriteButton addTarget:self action:@selector(didPushCancelFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.favoriteButton setButtonTitle:NSLocalizedString(@"Favorite", nil)];
        [cell.favoriteButton setButtonImage:[UIImage imageNamed:@"Star-Boarder-Tint"]];
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
    } else if (self.expandingDataSource.count > 0 && indexPath.row >= cellsOnCountCell) {
        NSInteger expandedIndex = indexPath.row - cellsOnCountCell;
        if (self.expandingDataSource.count - 1 < expandedIndex) {
            return;
        }
        NSDictionary *countDict = [self.expandingDataSource objectAtIndex:expandedIndex];
        NSString *identifier = [countDict objectForKey:contentIdentifier];
        if ([identifier isEqualToString:favoriteStr]) {
            ;
        } else if ([identifier isEqualToString:retweetStr]) {
            
        }
    }
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == actionSheet.destructiveButtonIndex){
        NSDictionary *userRetweetedTweet = self.tweet.currentUserRetweetedTweet;
        if (nil == userRetweetedTweet) {
            
        }
        NSNumber *retweetID = [userRetweetedTweet numberForKey:@"id"];
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

#pragma mark WebBrowsViewController Delegate
- (void)closeBrowsViewController:(MBWebBrowsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark AOuth_APICenterDelegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets
{
    if (requestType == MBTwitterStatusesShowSingleTweetRequest) {
        MBTweet *tweet = [tweets firstObject];
        if (tweet) {
            [self setTweet:tweet];
            [self.tableView reloadData];
        }
        return;
    }
    NSLog(@"requesttype = %d", requestType);
    if (requestType == MBTwitterStatusesRetweetsOfTweetRequest) {
        MBTweet *tweet = [tweets firstObject];
        if (tweet) {
            [self setTweet:tweet.tweetOfOriginInRetweet];
            [self.tableView reloadData];
        }
        return;
    }
    
    if (requestType == MBTwitterStatusesDestroyTweetRequest) {
        MBTweet *tweet = [tweets firstObject];
        self.tweet = tweet.tweetOfOriginInRetweet;
        [self.tableView reloadData];
        return;
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

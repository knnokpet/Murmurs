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

#import "MBTweetTextComposer.h"
#import "MBTweetManager.h"
#import "MBTweet.h"
#import "MBUser.h"
#import "MBEntity.h"
#import "MBMentionUserLink.h"

#import "MBMagnifierView.h"
#import "MBMagnifierRangeView.h"

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
        
        _expandingDataSource = [NSMutableArray array];
    }
    return self;
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setTweet:(MBTweet *)tweet
{
    _tweet = tweet;
    
    
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

- (IBAction)didPushFavoriteButton:(id)sender {
    [self.aoAPICenter postFavoriteForTweetID:[self.tweet.tweetID unsignedLongLongValue]];
}
- (IBAction)didPushUnFavoriteButton:(id)sender {
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
    CGFloat height = 48.0f;
    CGFloat verticalMargin = 10.0f;
    CGFloat horizontalMargin = 16.0f;
    CGFloat innnerVerticalMargin = 4.0f;
    CGFloat dateRetweetViewHeight = 20.0f;
    
    if (0 == indexPath.row) {
        height = 48.0f + (verticalMargin * 2);
    } else if (1 == indexPath.row) {
        
        NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
        
        NSInteger viewWidth = self.tableView.bounds.size.width - (horizontalMargin * 2);
        CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(viewWidth, CGFLOAT_MAX) lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:FONT_SIZE]];
        
        CGFloat bottomHeifht;
        if (self.retweeter) {
            bottomHeifht = dateRetweetViewHeight * 2 + innnerVerticalMargin * 3;
        } else {
            bottomHeifht = dateRetweetViewHeight + innnerVerticalMargin + verticalMargin;
        }

        height = textRect.size.height + verticalMargin + bottomHeifht;
    } else {
        height = 48.0f;
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
        MBDetailTweetTextTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
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
                [MBImageDownloader downloadBigImageWithURL:user.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                    if (image) {
                        [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:user.userIDStr];
                        CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                        UIImage *radiusImage = [MBImageApplyer imageForTwitter:image byScallingToFillSize:imageSize radius:cell.avatorImageView.layer.cornerRadius];
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
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:avatorImage byScallingToFillSize:imageSize radius:cell.avatorImageView.layer.cornerRadius];
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
    
    
    // retweet
    if (!self.retweeter) {
        [cell removeRetweetView];
    } else {
        NSString *retweetText = NSLocalizedString(@"Retweeted by ", nil);
        NSString *textWithUser = [NSString stringWithFormat:@"%@%@", retweetText, self.retweeter.characterName];
        cell.retweetView.attributedString = [MBTweetTextComposer attributedStringForTimelineDate:textWithUser font:[UIFont systemFontOfSize:14.0f] screeName:self.retweeter.screenName tweetID:[self.tweet.tweetID unsignedLongLongValue]];
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
    
    [cell.replyButton addTarget:self action:@selector(didPushReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell.retweetWithComentButton addTarget:self action:@selector(didPushRetweetWithComentButton:) forControlEvents:UIControlEventTouchUpInside];
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
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
    id obj = [tweets firstObject];
    NSLog(@"class %@ count %d", [obj class], [tweets count]);
    if ([obj isKindOfClass:[MBTweet class]]) {
        MBTweet *tweet = (MBTweet *)obj;
        [self setTweet:tweet];
        [self.tableView reloadData];
        
    }
}

#pragma mark TweetTextViewDelegate
- (void)tweetTextView:(MBTweetTextView *)textView clickOnLink:(MBLinkText *)linktext point:(CGPoint)touchePoint
{
    
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

@end

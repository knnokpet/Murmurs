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
#import "MBTextCacher.h"

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
#import "MBErrorView.h"
#import "MBAvatorImageView.h"

#import "MBDetailTweetUserTableViewCell.h"
#import "MBDetailTweetTextTableViewCell.h"
#import "MBDetailTweetActionsTableViewCell.h"
#import "MBDetailTweetFavoriteRetweetTableViewCell.h"
#import "MBDetailTweetImageTableViewCell.h"
#import "MBTweetViewCell.h"

#define DETAIL_LINE_SPACING 4.0f
#define DETAIL_LINE_HEIGHT 0.0f
#define DETAIL_PARAGRAPF_SPACING 0.0f
#define DETAIL_FONT_SIZE 20.0f

static NSString *userCellIdentifier = @"UserCellIdentifier";
static NSString *tweetCellIdentifier = @"TweetCellIdentifier";
static NSString *retweetCellIdentifier = @"RetweetCellIdentifier";
static NSString *countCellIdentifier = @"CountCellIdentifier";
static NSString *actionsCellIdentifier = @"ActionsCellIdentifier";
static NSString *imageCellIdentifier = @"ImageCellIdentifier";
static NSString *replyTweetCellIdentifier = @"ReplyTweetCellIdentifier";

static NSString *kUser = @"UserKey";
static NSString *kTweet = @"TweetKey";
static NSString *kCount = @"CountKey";
static NSString *kActions = @"ActionsKey";
static NSString *kMedia = @"MediaKey";
static NSString *kReply = @"ReplyKey";


@interface MBDetailTweetViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, MBAvatorImageViewDelegate>
{
    CGFloat lineSpacing;
    CGFloat lineHeight;
    CGFloat paragraphSpacing;
    CGFloat tweetFontSize;
}

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) NSMutableArray *replyedTweets;
@property (nonatomic, assign) BOOL fetchsReplyedTweet;/* unused */
@property (nonatomic) NSDictionary *currentUserRetweetedTweet;
@property (nonatomic) MBZoomTransitioning *zoomTransitoining;
@property (nonatomic, readonly) NSMutableArray *dataSource;

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

- (instancetype)initWithTweet:(MBTweet *)tweet
{
    self = [super init];
    if (self) {
        [self initializeConstantNumber];
        [self setTweet:tweet];
    }
    
    return self;
}

- (void)initializeConstantNumber
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.width > 320) {
        lineSpacing = 6.0f;
        lineHeight = 0.0f;
        paragraphSpacing = 2.0f;
        tweetFontSize = 18.0f;
    } else {
        lineSpacing = 2.0f;
        lineHeight = 0.0f;
        paragraphSpacing = 0.0f;
        tweetFontSize = 15.0f;
    }
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setTweet:(MBTweet *)tweet
{
    _tweet = tweet;
    [self configureDatasource];
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
    
    _dataSource = [NSMutableArray array];
    
    _replyedTweets = [NSMutableArray array];
    self.fetchsReplyedTweet = NO;
    
    [self configureDatasource];
}

- (void)configureDatasource
{
    if (!self.tweet) {
        return;
    }
    
    [self.dataSource removeAllObjects];
    
    NSArray *mainTweet = [self tweetCompositionsWithTweet:self.tweet];
    [self.dataSource addObject:mainTweet];
    
    if (self.tweet.tweetIDOfOriginInReply) {
        [self.dataSource addObject:@[kReply]];
    }
}

- (NSArray *)tweetCompositionsWithTweet:(MBTweet *)tweet
{
    if (!tweet) {
        return nil;
    }
    
    NSMutableArray *compositions = [NSMutableArray arrayWithObjects:kUser, kTweet, nil];
    if (tweet.favoritedCount > 0 || tweet.retweetedCount > 0) {
        [compositions addObject:kCount];
    }
    
    [compositions addObject:kActions];
    
    if (tweet.entity.media.count > 0) {
        [compositions addObject:kMedia];
    }
    
    return compositions;
}

- (void)configureViews
{
    if (!self.tableView) {
        
        UITableViewStyle style = (self.tweet.tweetIDOfOriginInReply) ? UITableViewStyleGrouped : UITableViewStylePlain;
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:style];
        [self.view addSubview:self.tableView];
        
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
        UINib *retweetCell = [UINib nibWithNibName:@"MBDetailTweetTextTableViewCell" bundle:nil];
        [self.tableView registerNib:retweetCell forCellReuseIdentifier:retweetCellIdentifier];
        UINib *countCell = [UINib nibWithNibName:@"MBDetailTweetFavoriteRetweetTableViewCell" bundle:nil];
        [self.tableView registerNib:countCell forCellReuseIdentifier:countCellIdentifier];
        UINib *actionsCell = [UINib nibWithNibName:@"MBDetailTweetActionsTableViewCell" bundle:nil];
        [self.tableView registerNib:actionsCell forCellReuseIdentifier:actionsCellIdentifier];
    }
    /* unused
    self.magnifierView = [[MBMagnifierView alloc] init];
    self.magnifierRangeView = [[MBMagnifierRangeView alloc] init];*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Tweet", nil);
    
    [self configureModel];
    
    if (self.tweet.requireLoading || self.tweet.isRetweeted) {
        [self.aoAPICenter getTweet:[self.tweet.tweetID unsignedLongLongValue]];
    }
    [self fetchTweetInReply:self.tweet];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureViews];
    
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
    
    [self updateVisibleCells];
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
            //[self fetchTweetInReply:replyedTweet];
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

- (void)showErrorViewWithErrorText:(NSString *)errorText
{
    MBErrorView *errorView = [[MBErrorView alloc] initWithErrorText:errorText];
    errorView.center = self.view.center;
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.view addSubview:errorView];
    }completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.5 delay:0.5 options:0 animations:^{
            errorView.alpha = 0.0;
        }completion:^(BOOL finished) {
            [errorView removeFromSuperview];
        }];
    }];
}

- (void)updateVisibleCells
{
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[MBTweetViewCell class]]) {
            MBTweetViewCell *tweetCell = (MBTweetViewCell *) cell;
            if (tweetCell.avatorImageView.isSelected) {
                [tweetCell.avatorImageView setIsSelected:NO  withAnimated:YES];
            }
            
            MBTweet *replyTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.tweet.tweetIDStrOfOriginInReply];
            if (!replyTweet) {
                [self fetchTweetInReply:self.tweet];
            }
            [self updateReplyCell:(MBTweetViewCell *)cell tweet:replyTweet];
        }
        
        if ([cell isKindOfClass:[MBDetailTweetTextTableViewCell class]]) {
            [self updateTweetViewCell:(MBDetailTweetTextTableViewCell *)cell];
        }
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
    
    [self.aoAPICenter postRetweetForTweetID:[self.tweet.tweetID unsignedLongLongValue]];
    /*
    UIActionSheet *retweetActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Retweet", @"Retweet with Coment", nil];
    [retweetActionSheet showFromTabBar:self.tabBarController.tabBar];*/
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
    UIActionSheet *retweetActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Cancel Retweet", nil) otherButtonTitles:nil];
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
- (CGFloat)tableView:(UITableView *)tableView heightForReplyedTweet:(MBTweet *)tweet
{
    BOOL isRetweet = NO;
    MBTweet *calcuTweet = tweet;
    if (tweet.tweetOfOriginInRetweet) {
        isRetweet = YES;
        calcuTweet = tweet.tweetOfOriginInRetweet;
        
    } else if (tweet.isRetweeted) {
        isRetweet = YES;
    }
    
    BOOL isPlace = NO;
    if (calcuTweet.place) {
        isPlace = YES;
    }
    
    BOOL containsImage = NO;
    if (calcuTweet.entity.media.count > 0) {
        containsImage = YES;
    }
    
    NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:calcuTweet tintColor:[self.navigationController.navigationBar tintColor]];
    
    CGFloat customCellHeight = [MBTweetViewCell heightForCellWithTweetText:attributedString constraintSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX) lineSpace:lineSpacing paragraphSpace:paragraphSpacing font:[UIFont systemFontOfSize:tweetFontSize] isRetweet:isRetweet isPlace:isPlace isMedia:containsImage];
    
    return customCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        MBTweet *replyTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.tweet.tweetIDStrOfOriginInReply];
        return [self tableView:tableView heightForReplyedTweet:replyTweet];
    }
    
    CGFloat height = 44.0f;
    CGFloat verticalMargin = 10.0f;
    CGFloat horizontalMargin = 16.0f;
    CGFloat dateMargin = 8.0f;
    CGFloat dateRetweetViewHeight = 20.0f;
    CGFloat marginBetweenDateRetweeter = 8.0f;
    CGFloat verticalMarginRetweeter = 10.0f;
    
    NSArray *tweetCompositions = [self tweetCompositionsWithTweet:self.tweet];
    if (tweetCompositions.count < indexPath.row) {
        return height;
    }
    
    NSString *compositionKey = [tweetCompositions objectAtIndex:indexPath.row];
    
    if ([compositionKey isEqualToString:kUser]) {
        height = 48.0f + (verticalMargin * 2);
        
    } else if ([compositionKey isEqualToString:kTweet]) {
        
        NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
        
        NSInteger viewWidth = self.tableView.bounds.size.width - (horizontalMargin * 2);
        CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(viewWidth, CGFLOAT_MAX) lineSpace:DETAIL_LINE_SPACING font:[UIFont systemFontOfSize:DETAIL_FONT_SIZE]];
        height = textRect.size.height + dateRetweetViewHeight + verticalMargin;
        
        CGFloat addingHeight = 0.0f;
        if (self.retweeter) {
            addingHeight = dateMargin + dateRetweetViewHeight + verticalMarginRetweeter + marginBetweenDateRetweeter;
        } else {
            addingHeight = dateMargin + verticalMargin;
        }

        height += addingHeight;
    }else if ([compositionKey isEqualToString:kActions]) {
        height = 56.0f;
    }else if ([compositionKey isEqualToString:kCount]) {
        height = 32.0f;
    } else if ([compositionKey isEqualToString:kMedia]) {
        MBMediaLink *mediaLink = [self.tweet.entity.media firstObject];
        UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:mediaLink.mediaIDStr];
        height = [MBDetailTweetImageTableViewCell heightWithImage:mediaImage constraintSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX) ];
    }
    
    
    
    return  height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    if (self.tweet.tweetIDOfOriginInReply) {
        sections = 2;
    }
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    if (section == 0) {
        rows = 3;
        if (self.tweet.retweetedCount > 0 || self.tweet.favoritedCount > 0) {
            rows += 1;
        }
        if (self.tweet.entity.media.count > 0) {
            rows += 1;
        }
        
    } else {
        rows = 1;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *compositionKey = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([compositionKey isEqualToString:kUser]) {
        MBDetailTweetUserTableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:userCellIdentifier];
        [self updateUserCell:userCell];
        cell = userCell;
    } else if ([compositionKey isEqualToString:kTweet]) {
        
        MBDetailTweetTextTableViewCell *textCell;
        if (self.retweeter) {
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
    } else if ([compositionKey isEqualToString:kActions]) {
        MBDetailTweetActionsTableViewCell *actionsCell = [self.tableView dequeueReusableCellWithIdentifier:actionsCellIdentifier];
        [self updateActionsCell:actionsCell];
        cell = actionsCell;
    } else if ([compositionKey isEqualToString:kCount]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:countCellIdentifier];
        if (!cell) {
            cell = [[MBDetailTweetFavoriteRetweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:countCellIdentifier];
        }
        [self updateCountCell:(MBDetailTweetFavoriteRetweetTableViewCell *)cell atIndexPath:indexPath];
    } else if ([compositionKey isEqualToString:kMedia]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
        if (!cell) {
            cell = [[MBDetailTweetImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier];
            [self updateImageCell:(MBDetailTweetImageTableViewCell *)cell];
        }
    } else if ([compositionKey isEqualToString:kReply]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:replyTweetCellIdentifier];
        if (!cell) {
            cell = [[MBTweetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyTweetCellIdentifier];
        }
        MBTweet *replyTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.tweet.tweetIDStrOfOriginInReply];
        if (!replyTweet) {
            [self fetchTweetInReply:self.tweet];
        }
        [self updateReplyCell:(MBTweetViewCell *)cell tweet:replyTweet];
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
    
    [self composeTweetDateCell:cell];
    
    // retweet
    if (!self.retweeter) {
        [cell removeRetweetView];
    } else {
        cell.retweeterView.retweeterString  = [MBTweetTextComposer attributedStringForTimelineRetweeter:self.retweeter font:[UIFont systemFontOfSize:14.0f]];
        cell.retweeterView.delegate = self;
        NSAttributedString *retweeterName = [MBTweetTextComposer attributedStringForTimelineRetweeter:self.retweeter font:[UIFont systemFontOfSize:14.0f]];
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
    
    /*
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
    }*/
}

- (void)composeTweetDateCell:(MBDetailTweetTextTableViewCell *)cell
{
    // parse 時に strp で locale を計算した createDate を作成しているので。
    NSCalendar *calendaar = [NSCalendar currentCalendar];
    NSTimeZone *currentTimezone = calendaar.timeZone;
    if (!self.tweet.createdDate) {
        return;
    }
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
}

- (void)updateCountCell:(MBDetailTweetFavoriteRetweetTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell setIsRetweeted:self.tweet.isRetweeted];
    [cell setIsFavorited:self.tweet.isFavorited];
    [cell setRetweetCount:self.tweet.retweetedCount];
    [cell setFavoriteCount:self.tweet.favoritedCount];
}

- (void)updateActionsCell:(MBDetailTweetActionsTableViewCell *)cell
{
    [cell.replyButton setButtonTitle:NSLocalizedString(@"Reply", nil)];
    [cell.replyButton setButtonImage:[UIImage imageNamed:@"reply-TintBlue"]];
    [cell.replyButton addTarget:self action:@selector(didPushReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // retweet
    if (self.tweet.isRetweeted) {
        [cell.retweetButton setButtonTitle:NSLocalizedString(@"Cancel", nil)];
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
        [cell.favoriteButton setButtonTitle:NSLocalizedString(@"Cancel", nil)];
        [cell.favoriteButton setButtonImage:[UIImage imageNamed:@"Star-Cancel-TintBlue"]];
        [cell.favoriteButton addTarget:self action:@selector(didPushCancelFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.favoriteButton setButtonTitle:NSLocalizedString(@"Favorite", nil)];
        [cell.favoriteButton setButtonImage:[UIImage imageNamed:@"Star-TintBlue"]];
        [cell.favoriteButton addTarget:self action:@selector(didPushFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)updateImageCell:(MBDetailTweetImageTableViewCell *)cell
{
    // mediaImage
    NSInteger imageCounts = self.tweet.entity.media.count;
    if (imageCounts > 0) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            int i = 0;
            for (MBMediaLink *mediaLink in self.tweet.entity.media) {
                UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:mediaLink.mediaIDStr];
                
                if (mediaImage) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView beginUpdates];
                        cell.mediaImage = mediaImage;
                        [self.tableView endUpdates];
                    });
                    
                } else {
                    
                    [MBImageDownloader downloadMediaImageWithURL:mediaLink.originalURLHttpsText completionHandler:^(UIImage *image, NSData *imageData) {
                        if (image) {
                            [[MBImageCacher sharedInstance] storeMediaImage:image data:imageData forMediaID:mediaLink.mediaIDStr];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView beginUpdates];
                                cell.mediaImage = mediaImage;
                                [self.tableView endUpdates];
                            });
                        }
                        
                    } failedHandler:^(NSURLResponse *response, NSError *error) {
                        
                    }];
                }
                i++;
            }
        });
    }
}

- (void)updateReplyCell:(MBTweetViewCell *)cell tweet:(MBTweet *)tweet
{
    if (!tweet) {
        ;
        return;
    }
    
    // Retweet
    MBTweet *tweetForUpdating = tweet;
    if (tweet.tweetOfOriginInRetweet || tweet.isRetweeted) {
        tweetForUpdating = [[MBTweetManager sharedInstance] storedTweetForKey:tweet.tweetOfOriginInRetweet.tweetIDStr];
        [cell setRequireRetweet:YES];
        
        NSAttributedString *retweeterName = [MBTweetTextComposer attributedStringForTimelineRetweeter:tweet.tweetUser font:[UIFont systemFontOfSize:14.0f]];
        MBUser *linkUser = tweet.tweetUser;
        if (tweet.isRetweeted) {
            retweeterName = [MBTweetTextComposer attributedStringByRetweetedMeForTimelineWithfont:[UIFont systemFontOfSize:14.0f]];
            linkUser = [[MBUserManager sharedInstance] storedUserForKey:[[MBAccountManager sharedInstance]currentAccount].userID];
        }
        [cell.retweeterView setRetweeterString:retweeterName];
        [cell.retweeterView setUserLink:[[MBMentionUserLink alloc]initWithUserID:linkUser.userID IDStr:linkUser.userIDStr screenName:linkUser.screenName]];
        cell.retweeterView.delegate = self;
    } else {
        [cell setRequireRetweet:NO];
    }
    
    MBUser *userAtIndexPath = tweetForUpdating.tweetUser;
    
    // timeView
    NSString *timeIntervalString = [NSString timeMarginWithDate:tweetForUpdating.createdDate];
    [cell setDateString:[MBTweetTextComposer attributedStringForTimelineDate:timeIntervalString font:[UIFont systemFontOfSize:12.0f] screeName:userAtIndexPath.screenName tweetID:[tweetForUpdating.tweetID unsignedLongLongValue]]];
    cell.dateView.delegate = self;
    
    // charaScreenNameView
    NSAttributedString *attrCharacterName = [[MBTextCacher sharedInstance] cachedUserNameWithUserIDStr:tweetForUpdating.tweetUser.userIDStr];
    if (!attrCharacterName) {
        attrCharacterName = [MBTweetTextComposer attributedStringForTimelineUser:tweetForUpdating.tweetUser charFont:[UIFont boldSystemFontOfSize:15.0f] screenFont:[UIFont systemFontOfSize:14.0f]];
        [[MBTextCacher sharedInstance] storeUserName:attrCharacterName key:tweetForUpdating.tweetUser.userIDStr];
    }
    [cell setCharaScreenString:[MBTweetTextComposer attributedStringForTimelineUser:tweetForUpdating.tweetUser charFont:[UIFont boldSystemFontOfSize:15.0f] screenFont:[UIFont systemFontOfSize:14.0f]]];
    
    // tweetText
    cell.tweetTextView.font = [UIFont systemFontOfSize:tweetFontSize];
    cell.tweetTextView.lineSpace = lineSpacing;
    cell.tweetTextView.lineHeight = lineHeight;
    cell.tweetTextView.paragraphSpace = paragraphSpacing;
    NSAttributedString *attrTweetText = [[MBTextCacher sharedInstance] cachedTweetTextWithTweetIDStr:tweetForUpdating.tweetIDStr];
    if (!attrTweetText) {
        attrTweetText = [MBTweetTextComposer attributedStringForTweet:tweetForUpdating tintColor:[self.navigationController.navigationBar tintColor]];
        [[MBTextCacher sharedInstance] storeTweetText:attrTweetText key:tweetForUpdating.tweetIDStr];
    }
    cell.tweetTextView.attributedString = attrTweetText;
    cell.tweetTextView.delegate = self;
    
    // geo
    if (tweetForUpdating.place) {
        [cell setRequirePlace:YES];
        cell.placeString = [MBTweetTextComposer attributedStringForTimelinePlace:tweetForUpdating.place font:[UIFont systemFontOfSize:15.0f]];
    } else {
        [cell setRequirePlace:NO];
    }
    
    // favorite
    [cell setRequireFavorite:tweetForUpdating.isFavorited];
    
    // AvatorImageView
    [self updateAvatorImageForCell:cell user:userAtIndexPath];
    
    
    // mediaImage
    [self updateMediaImageForCell:cell tweet:tweetForUpdating];
}

- (void)updateAvatorImageForCell:(MBTweetViewCell *)cell user:(MBUser *)user
{
    cell.userID = user.userID;
    cell.avatorImageView.delegate = self;
    
    if (cell.avatorImageView.avatorImage && [cell.avatorImageView.userIDStr isEqualToString:user.userIDStr]) {
        return;
    }
    
    cell.userIDStr = user.userIDStr;
    cell.avatorImageView.userIDStr = user.userIDStr;
    cell.avatorImageView.avatorImage = nil;
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedTimelineImageForUser:user.userIDStr];
    if (!avatorImage) {
        
        __weak MBDetailTweetViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [MBImageDownloader downloadOriginImageWithURL:user.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:user.userIDStr];
                    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:cell.avatorImageViewSize radius:cell.avatorImageViewRadius];
                    [[MBImageCacher sharedInstance] storeTimelineImage:radiusImage forUserID:user.userIDStr];
                    
                    [[MBImageCacher sharedInstance] removeUrlStrForDownloadingImage:user.urlHTTPSAtProfileImage];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([cell.userIDStr isEqualToString:user.userIDStr]) {
                            if (weakSelf.tableView.dragging || weakSelf.tableView.decelerating) {
                                return;
                            }
                            [cell addAvatorImage:radiusImage];
                        }
                    });
                }
                
            }failedHandler:^(NSURLResponse *response, NSError *error){
                [[MBImageCacher sharedInstance] removeUrlStrForDownloadingImage:user.urlHTTPSAtProfileImage];
            }];
            
        });
    } else {
        [cell addAvatorImage:avatorImage];
    }
}

- (void)updateMediaImageForCell:(MBTweetViewCell *)cell tweet:(MBTweet *)tweet
{
    __weak MBDetailTweetViewController *weakSelf = self;
    NSInteger imageCounts = tweet.entity.media.count;
    if (imageCounts == 0) {
        [cell setRequireMediaImage:NO];
        return;
    }
    [cell setRequireMediaImage:YES];
    
    int i = 0;
    for (MBMediaLink *mediaLink in tweet.entity.media) {
        MBMediaImageView *mediaImageView = cell.mediaImageView;
        if (mediaImageView.mediaImage && [mediaImageView.mediaIDStr isEqualToString:mediaLink.mediaIDStr]) {
            i++;
            continue;
        } else {
            mediaImageView.mediaImage = nil;
        }
        
        //mediaImageView.delegate = weakSelf;
        mediaImageView.mediaHTTPURLString = mediaLink.originalURLHttpsText;
        mediaImageView.mediaIDStr = mediaLink.mediaIDStr;
        
        UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedCroppedMediaImageForMediaID:mediaLink.mediaIDStr];
        if (mediaImage) {
            /* Require refactoring!!! */
            mediaImageView.alpha = 0;
            mediaImageView.mediaImage = mediaImage;
            [UIView animateWithDuration:0.3f animations:^{
                mediaImageView.alpha = 1.0;
                
            }];
            
        } else {
            [[MBImageCacher sharedInstance] addUrlStrForDownloadingImage:mediaLink.originalURLHttpsText];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [MBImageDownloader downloadMediaImageWithURL:mediaLink.originalURLHttpsText completionHandler:^(UIImage *image, NSData *imageData) {
                    if (image) {
                        [[MBImageCacher sharedInstance] storeMediaImage:image data:imageData forMediaID:mediaLink.mediaIDStr];
                        
                        CGSize mediaImageSize = CGSizeMake(mediaImageView.frame.size.width, mediaImageView.frame.size.height);
                        UIImage *croppedImage = [MBImageApplyer imageForMediaWithImage:image size:mediaImageSize];
                        
                        [[MBImageCacher sharedInstance] storeCroppedMediaImage:croppedImage forMediaID:mediaLink.mediaIDStr];
                        
                        [[MBImageCacher sharedInstance] removeUrlStrForDownloadingImage:mediaLink.originalURLHttpsText];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([mediaImageView.mediaIDStr isEqualToString:mediaLink.mediaIDStr]) {
                                if (weakSelf.tableView.dragging || weakSelf.tableView.decelerating) {
                                    return;
                                }
                                
                                mediaImageView.alpha = 0;
                                mediaImageView.mediaImage = croppedImage;
                                [UIView animateWithDuration:0.3f animations:^{
                                    mediaImageView.alpha = 1.0;
                                }];
                            }
                        });
                    }
                    
                } failedHandler:^(NSURLResponse *response, NSError *error) {
                    [[MBImageCacher sharedInstance] removeUrlStrForDownloadingImage:mediaLink.originalURLHttpsText];
                }];
            });
        }
        i++;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        MBUser *selectedUser = self.tweet.tweetUser;
        MBDetailUserViewController *userViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
        [userViewController setUser:selectedUser];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == 1) {
        MBTweet *selectedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.tweet.tweetIDStrOfOriginInReply];
        MBUser *retweeter = nil;
        
        if (nil != selectedTweet.tweetOfOriginInRetweet) {
            retweeter = selectedTweet.tweetUser;
            MBTweet *retweetedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:selectedTweet.tweetOfOriginInRetweet.tweetIDStr];
            if (!retweetedTweet) {
                retweetedTweet = selectedTweet.tweetOfOriginInRetweet;
            }
            selectedTweet = retweetedTweet;
            
        } else if (selectedTweet.isRetweeted) {
            retweeter = [[MBUserManager sharedInstance] storedUserForKey:[MBAccountManager sharedInstance].currentAccount.userID];
            
        }
        
        MBDetailTweetViewController *detailTweetViewController = [[MBDetailTweetViewController alloc] initWithTweet:selectedTweet];
        [detailTweetViewController setRetweeter:retweeter];
        [self.navigationController pushViewController:detailTweetViewController animated:YES];
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
    MBTweet *tweet = [tweets firstObject];
    if (!tweet) {
        return;
    }
    
    if (requestType == MBTwitterStatusesShowSingleTweetRequest) {
        if ([tweet.tweetIDStr isEqualToString:self.tweet.tweetIDStrOfOriginInReply]) {
            NSIndexPath *replyedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:replyedIndexPath];
            [self.tableView beginUpdates];
            [self updateReplyCell:(MBTweetViewCell *)cell tweet:tweet];
            [self.tableView endUpdates];
        } else {
            [self setTweet:tweet];
            [self.tableView reloadData];
        }
        
    } else if (requestType == MBTwitterStatusesRetweetsOfTweetRequest) {
        if (!self.retweeter || [[[[MBAccountManager sharedInstance] currentAccount] userID] isEqualToString:self.retweeter.userIDStr] == NO ) {
            self.retweeter = [[MBUserManager sharedInstance] storedUserForKey:[[[MBAccountManager sharedInstance] currentAccount] userID]];
        }
        self.currentUserRetweetedTweet = @{@"id": tweet.tweetID};
        self.tweet = tweet.tweetOfOriginInRetweet;
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
        if (tweet.favoritedCount == 1) {
            [self.tableView reloadData];
        } else {
            NSIndexPath *countCellPath = [NSIndexPath indexPathForRow:2 inSection:0];
            MBDetailTweetFavoriteRetweetTableViewCell *cell = (MBDetailTweetFavoriteRetweetTableViewCell *)[self.tableView cellForRowAtIndexPath:countCellPath];
            [self updateCountCell:cell atIndexPath:countCellPath];
            NSIndexPath *actionsCellPath = [NSIndexPath indexPathForRow:countCellPath.row + 1 inSection:0];
            MBDetailTweetActionsTableViewCell *actionsCell = (MBDetailTweetActionsTableViewCell *)[self.tableView cellForRowAtIndexPath:actionsCellPath];
            [self updateActionsCell:actionsCell];
        }
        
    } else if (requestType == MBTwitterFavoritesDestroyRequest) {
        [self setTweet:tweet];
        if (tweet.favoritedCount == 0) {
            [self.tableView reloadData];
        } else {
            NSIndexPath *countCellPath = [NSIndexPath indexPathForRow:2 inSection:0];
            MBDetailTweetFavoriteRetweetTableViewCell *cell = (MBDetailTweetFavoriteRetweetTableViewCell *)[self.tableView cellForRowAtIndexPath:countCellPath];
            [self updateCountCell:cell atIndexPath:countCellPath];
            NSIndexPath *actionsCellPath = [NSIndexPath indexPathForRow:countCellPath.row + 1 inSection:0];
            MBDetailTweetActionsTableViewCell *actionsCell = (MBDetailTweetActionsTableViewCell *)[self.tableView cellForRowAtIndexPath:actionsCellPath];
            [self updateActionsCell:actionsCell];
        }
        
    } else if (requestType == MBTwitterStatusesUpdateRequest) {
        
    }
    
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center error:(NSError *)error
{
    [self showErrorViewWithErrorText:error.localizedDescription];
}
/*  unused
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
}*/

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

/*
#pragma mark ImageViewController Delegate
- (void)dismissImageViewController:(MBImageViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}*/

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

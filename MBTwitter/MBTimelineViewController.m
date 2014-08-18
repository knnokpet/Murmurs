//
//  MBTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"


static NSString *tweetCellIdentifier = @"TweetTableViewCellIdentifier";
static NSString *tweetWithImageCellIdentifier = @"TweetWithImageTableViewCellIdentifier";
static NSString *favoriteCellIdentifier = @"FavoriteTableViewCellIdentifier";
static NSString *favoriteWithImageCellIdentifier = @"FavoriteWithImageTableViewCellIdentifier";

static NSString *placeCellIdentifier = @"PlaceTableViewCellIdentifier";
static NSString *placeWithImageCellIdentifier = @"PlaceWithImageTableViewCellIdentifier";
static NSString *placeFavoriteCellIdentifier = @"PlaceFavoriteTableViewCellIdentifier";
static NSString *placeFavoriteWithImageCellIdentifier = @"PlaceFavoriteWithImageTableViewCellIdentifier";

static NSString *retweetCellIdentifier = @"RetweetTableViewCellIdentifier";
static NSString *retweetWithImageCellIdentifier = @"RetweetWithImageTableViewCellIdentifier";
static NSString *favoriteRetweetCellIdentifier = @"FavoriteRetweetTableViewCellIdentifier";
static NSString *favoriteRetweetWithImageCellIdentifier = @"FavoriteRetweetWithImageTableViewCellIdentifier";

static NSString *retweetPlaceCellIdentifier = @"RetweetPlaceTableViewCellIdentifier";
static NSString *retweetPlaceWithImageCellIdentifier = @"RetweePlacetWithImageTableViewCellIdentifier";
static NSString *favoriteRetweetPlaceCellIdentifier = @"FavoriteRetweetPlaceTableViewCellIdentifier";
static NSString *favoriteRetweetPlaceWithImageCellIdentifier = @"FavoriteRetweetPlaceWithImageTableViewCellIdentifier";

static NSString *gapedCellIdentifier = @"GapedTweetTableViewCellIdentifier";

@interface MBTimelineViewController ()

@property (nonatomic) MBTwitterAccesser *twitterAccesser;

@property (nonatomic) MBZoomTransitioning *zoomTransitioning;

@property (nonatomic) NSInteger saveIndex;
@property (nonatomic, assign) BOOL backsTimeline;

@end

@implementation MBTimelineViewController

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

- (void)configureTimelineManager
{
    // override
    // アカウントの変更時に Home, Reply の timelineManager を保持するために、継承メソッドに
    _timelineManager = [[MBTimeLineManager alloc] init];
    self.dataSource = self.timelineManager.tweets;
}

- (void)commonConfigureModel
{
    [self configureTimelineManager];
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    self.aoAPICenter.delegate = self;
    self.enableBacking = YES;
    self.backsTimeline = NO;
    
    self.saveIndex = 0;
}

#pragma mark -
#pragma mark View
- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // cell
    UINib *cellNib = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:tweetCellIdentifier];
    UINib *retweetCel = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:retweetCel forCellReuseIdentifier:retweetCellIdentifier];
    UINib *favoriteCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:favoriteCell forCellReuseIdentifier:favoriteCellIdentifier];
    UINib *favoriteRetweetCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:favoriteRetweetCell forCellReuseIdentifier:favoriteRetweetCellIdentifier];
    
        // place
    UINib *placeCellNib = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:placeCellNib forCellReuseIdentifier:placeCellIdentifier];
    UINib *retweetPlaceCel = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:retweetPlaceCel forCellReuseIdentifier:retweetPlaceCellIdentifier];
    UINib *favoritePlaceCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:favoritePlaceCell forCellReuseIdentifier:placeFavoriteCellIdentifier];
    UINib *favoriteRetweetPlaceCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:favoriteRetweetPlaceCell forCellReuseIdentifier:favoriteRetweetPlaceCellIdentifier];
    
    
    // imageCell
    UINib *cellWithImageNib = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:cellWithImageNib forCellReuseIdentifier:tweetWithImageCellIdentifier];
    UINib *retweetWithImageCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:retweetWithImageCell forCellReuseIdentifier:retweetWithImageCellIdentifier];
    UINib *favoriteWithImageCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:favoriteWithImageCell forCellReuseIdentifier:favoriteWithImageCellIdentifier];
    UINib *favoriteRetweetWithImageCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:favoriteRetweetWithImageCell forCellReuseIdentifier:favoriteRetweetWithImageCellIdentifier];
    
        // place
    UINib *placeCellWithImageNib = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:placeCellWithImageNib forCellReuseIdentifier:placeWithImageCellIdentifier];
    UINib *retweetPlaceWithImageCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:retweetPlaceWithImageCell forCellReuseIdentifier:retweetPlaceWithImageCellIdentifier];
    UINib *placeFavoriteWithImageCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:placeFavoriteWithImageCell forCellReuseIdentifier:placeFavoriteWithImageCellIdentifier];
    UINib *placeFavoriteRetweetWithImageCell = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:placeFavoriteRetweetWithImageCell forCellReuseIdentifier:favoriteRetweetPlaceWithImageCellIdentifier];
    
    
    UINib *gapedCellNib = [UINib nibWithNibName:@"GapedTweetTableViewCell" bundle:nil];
    [self.tableView registerNib:gapedCellNib forCellReuseIdentifier:gapedCellIdentifier];
    
    // remove nonCell separator
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = view;
    
    // backTimelineIndicator
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    CGFloat bottomMargin = 4.0f;
    CGFloat indicatorHeight = indicatorView.frame.size.height;
    UIView *indicatorContanerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, indicatorHeight + bottomMargin * 2)];
    [indicatorContanerView addSubview:indicatorView];
    indicatorView.center = indicatorContanerView.center;
    self.tableView.tableFooterView = indicatorContanerView;
    
    
    // refreshControl
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self configureLoadingView];
}

- (void)configureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushLeftBarButtonItem)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(didPushRightBarButtonItem)];
}

- (void)commonConfigureNavigationItem
{
    [self configureNavigationItem];
}

- (void)configureLoadingView
{
    if (!self.loadingView.superview) {
        _loadingView = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.loadingView aboveSubview:self.tableView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self commonConfigureModel];
    [self commonConfigureView];
    
    // 回線状態が良かったら解放するというのもアリ
    [[MBImageCacher sharedInstance] deleteAllCacheFiles];
    
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount] ) {
        [self goBacksAtIndex:0];
    } else {
        MBAccountManager *accountManager = [MBAccountManager sharedInstance];
        [accountManager requestAccessToAccountWithCompletionHandler:^ (BOOL granted, NSArray *accounts, NSError *error) {
            if (!granted) {
                //
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.twitterAccesser = [[MBTwitterAccesser alloc] init];
                    self.twitterAccesser.delegate = self;
                    for (ACAccount *account in accounts) {
                        [self.twitterAccesser requestReverseRequestTokenWithAccount:account];
                    }
                });
            }
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
    
    for (MBTweetViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[MBGapedTweetViewCell class]]) {
            continue;
        }
        
        if (cell.avatorImageView.isSelected) {
            [cell.avatorImageView setIsSelected:NO  withAnimated:YES];
        }
        
        NSIndexPath *updatingIndexPath = [self.tableView indexPathForCell:cell];
        MBTweet *visibleTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[self.dataSource objectAtIndex:updatingIndexPath.row]];
        MBTweet *updatingTweet = visibleTweet;
        if (visibleTweet.tweetOfOriginInRetweet) {
            updatingTweet = visibleTweet.tweetOfOriginInRetweet;
        }
        [self updateCell:cell tweet:updatingTweet AtIndexPath:updatingIndexPath];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // crearCache
    [[MBImageCacher sharedInstance] clearMemoryCache];
}

#pragma mark - 
#pragma mark Instance Methods
- (void)removeLoadingView
{
    // ラウンチ時に表示されている UIActivityView を remove
    if (self.loadingView.superview) {
        [UIView animateWithDuration:0.3f animations:^{
            self.loadingView.alpha = 0.0f;
        }completion:^(BOOL finished){
            [self.loadingView removeFromSuperview];
            _loadingView = nil;
        }];
    }
}

- (void)removeBackTimelineIndicatorView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
}

#pragma mark save & load Tweets
- (void)saveTimeline
{
    NSArray *saveTweets = self.dataSource;
    [[MBTweetManager sharedInstance] saveTimeline:saveTweets];
}

- (void)goBacksAtIndex:(NSInteger )index
{
    if (self.enableBacking == NO) {
        return;
    }
    
    self.enableBacking = NO;
    self.backsTimeline = YES;
    if (0 == index) {
        NSArray *savedTweets = [self savedTweetsAtIndex:index];
        if (0 < [savedTweets count]) {
            [self updateTableViewDataSource:savedTweets];
            self.saveIndex++;
        } else {
            self.saveIndex = -1;
            [self backTimeline];
        }
    }else if (0 < index) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *savedTweets = [self savedTweetsAtIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (0 < [savedTweets count]) {
                    [self updateTableViewDataSource:savedTweets];
                    self.saveIndex++;
                } else {
                    self.saveIndex = -1;
                    [self backTimeline];
                }
            });
        });
        
    }else {
        [self backTimeline];
    }
}


- (NSArray *)savedTweetsAtIndex:(NSInteger)index
{
    // be override
    return nil;
}

- (void)backTimeline
{
    unsigned long long maxid;
    if (0 < [self.dataSource count]) {
        
        MBTweet *lastTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[self.dataSource lastObject]];
        maxid = [lastTweet.tweetID unsignedLongLongValue] - 1;
    } else {
        maxid = 0;
    }
    [self goBackTimelineMaxID:maxid];
}

- (void)goBackTimelineMaxID:(unsigned long long)max
{
    // be override
}

#pragma mark Action
- (void)didPushLeftBarButtonItem
{
    // be override
}

- (void)didPushRightBarButtonItem
{
    // be override
}

- (void)didPushGapButton:(id)sender
{
    if (sender) {
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            NSLog(@"row = %d", button.tag);
            
            NSString *maxStr = [self.dataSource objectAtIndex:button.tag - 1];
            MBTweet *maxTweet = [[MBTweetManager sharedInstance] storedTweetForKey:maxStr];
            unsigned long long maxID = [maxTweet.tweetID unsignedLongLongValue] - 1;
            
            NSString *sinceStr = [self.dataSource objectAtIndex:button.tag + 2];
            MBTweet *sinceTweet = [[MBTweetManager sharedInstance] storedTweetForKey:sinceStr];
            unsigned long long sinceID = [sinceTweet.tweetID unsignedLongLongValue];
            [self didPushGapButtonSinceID:sinceID max:maxID];
        }
    }
}

- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max
{
    // be override
}

- (void)refreshMyAccountUser
{
    // overridden
}

- (void)refreshAction
{
    if (0 == [self.dataSource count]) {
        [self goBacksAtIndex:0];
        return;
    }
    
    NSInteger since = 0 + 1;
    
    MBTweet *sinceTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.dataSource[since]];
    [self goForwardTimelineSinceID:[sinceTweet.tweetID unsignedLongLongValue]];
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    // override
}

#pragma mark -
- (CGFloat)calculateHeightTableView:(UITableView *)tableView tweet:(MBTweet *)tweet key:(NSString *)key
{
    UITableView *tableViewForCalculate = tableView;
    if (!tableView) {
        tableViewForCalculate = self.tableView;
    }
    
    if ([tweet isKindOfClass:[MBGapedTweet class]]) {
        return 48.0;
    }
    
    CGFloat avatorMargin = 12.0f;
    CGFloat avatorHeight = 48.0f;
    CGFloat defaultHeight = avatorHeight + avatorMargin * 2;
    
    BOOL isRetweet = NO;
    MBTweet *calcuTweet = tweet;
    if (tweet.tweetOfOriginInRetweet) {
        isRetweet = YES;
        calcuTweet = tweet.tweetOfOriginInRetweet;
        
        defaultHeight = avatorHeight + avatorMargin + 18.0f + 4 * 2;
    } else if (tweet.isRetweeted) {
        isRetweet = YES;
        defaultHeight = avatorHeight + avatorMargin + 18.0f + 4 * 2;
    }
    
    BOOL isPlace = NO;
    if (calcuTweet.place) {
        isPlace = YES;
        
        defaultHeight = avatorHeight + avatorMargin + 18.0f + 4 * 2;
    }
    
    BOOL containsImage = NO;
    if (calcuTweet.entity.media.count > 0) {
        containsImage = YES;
    }
    
    
    NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:calcuTweet tintColor:[self.navigationController.navigationBar tintColor]];
    
    
    NSInteger textViewWidth = tableViewForCalculate.bounds.size.width - (64.0f + 8.0f);
    CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(textViewWidth, CGFLOAT_MAX) lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:FONT_SIZE]];
    
    CGFloat tweetViewSpace = 32.0f;
    CGFloat verticalMargin = 10.0f;
    
    CGFloat bottomHeight = 0.0f;
    if (isRetweet && isPlace) {
        CGFloat retweetMargin = 4.0f;
        bottomHeight = 18.0f * 2 + retweetMargin * 3;
    } else if (isRetweet) {
        CGFloat retweetMargin = 4.0f;
        bottomHeight = 18.0f + retweetMargin * 2;
    } else if (isPlace) {
        CGFloat retweetMargin = 4.0f;
        bottomHeight = 18.0f + retweetMargin * 2;
    }
    else {
        bottomHeight = verticalMargin;
    }

    if (containsImage) {
        CGFloat imageMargin = 8.0f;
        bottomHeight += 128 + imageMargin;
    }
    
    CGFloat customCellHeight = textRect.size.height + tweetViewSpace + bottomHeight;
    
    return MAX(defaultHeight, customCellHeight);
}

#pragma mark UITableView DataSource & Delegate
/*
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80; // 設定してると scrollsToTop がうまく働かなくなるんだけd.
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:key];
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[MBGapedTweet class]]) {
        tweet = [self.dataSource objectAtIndex:indexPath.row];
    }
    CGFloat height = [self calculateHeightTableView:tableView tweet:tweet key:key];

    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[MBGapedTweet class]]) {
        MBGapedTweet *gapedTweet = [self.dataSource objectAtIndex:indexPath.row];
        MBGapedTweetViewCell *gapedCell = [self.tableView dequeueReusableCellWithIdentifier:gapedCellIdentifier];
        [gapedCell.gapButton addTarget:self action:@selector(didPushGapButton:) forControlEvents:UIControlEventTouchUpInside];
        gapedCell.gapButton.tag = gapedTweet.index;
        NSLog(@"gape cell");
        return gapedCell;
    }
    
    MBTweetViewCell *cell;
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBTweet *tweetAtIndex = [[MBTweetManager sharedInstance] storedTweetForKey:key];
    MBTweet *tweetForUpdating = tweetAtIndex;
    BOOL requireRetweet = NO;
    BOOL requireImage = NO;
    BOOL requirePlace = NO;
    BOOL requireFavorite = NO;
    
    // check retweet
    if (tweetAtIndex.tweetOfOriginInRetweet || tweetAtIndex.isRetweeted) {
        tweetForUpdating = tweetAtIndex.tweetOfOriginInRetweet;
        NSInteger imageCount = [tweetForUpdating.entity.media count];
        requireRetweet = YES;
        
        NSString *identifier;
        if (tweetForUpdating.isFavorited && tweetForUpdating.place) {
            identifier = favoriteRetweetPlaceCellIdentifier;
            requirePlace = YES;
            requireFavorite = YES;
            
            if (imageCount > 0) {
                identifier = favoriteRetweetPlaceWithImageCellIdentifier;
                requireImage = YES;
            }
            
        } else if (tweetForUpdating.isFavorited) {
            identifier = favoriteRetweetCellIdentifier;
            requireFavorite = YES;
            
            if (imageCount > 0) {
                identifier = favoriteRetweetWithImageCellIdentifier;
                requireImage = YES;
            }
            
        } else if (tweetForUpdating.place) {
            identifier = retweetPlaceCellIdentifier;
            requirePlace = YES;
            if (imageCount > 0) {
                identifier = retweetPlaceWithImageCellIdentifier;
                requireImage = YES;
            }
        } else {
            identifier = retweetCellIdentifier;
            if (imageCount > 0) {
                identifier = retweetWithImageCellIdentifier;
                requireImage = YES;
            }
        }
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];

        /* retweetView が必ずある状態で、という考えでここに */
        /* retweetTweet の代入もあるのでここに */
        //cell.retweetView.attributedString = [MBTweetTextComposer attributedStringForTimelineRetweeter:tweetAtIndex.tweetUser font:[UIFont systemFontOfSize:15.0f]];
        //cell.retweetView.delegate = self;
        NSAttributedString *retweeterName = [MBTweetTextComposer attributedStringForTimelineRetweeter:tweetAtIndex.tweetUser font:[UIFont systemFontOfSize:15.0f]];
        if ([[MBAccountManager sharedInstance].currentAccount.userID isEqualToString:tweetAtIndex.tweetUser.userIDStr]) {
            retweeterName = [MBTweetTextComposer attributedStringByRetweetedMeForTimelineWithfont:[UIFont systemFontOfSize:15.0f]];
        }
        [cell.retweeterView setRetweeterString:retweeterName];
        [cell.retweeterView setUserLink:[[MBMentionUserLink alloc]initWithUserID:tweetAtIndex.tweetUser.userID IDStr:tweetAtIndex.tweetUser.userIDStr screenName:tweetAtIndex.tweetUser.screenName]];
        cell.retweeterView.delegate = self;
        
    } else {
        NSInteger imageCount = tweetAtIndex.entity.media.count;
        NSString *identifier;
        if (tweetForUpdating.isFavorited && tweetForUpdating.place) {
            identifier = placeFavoriteCellIdentifier;
            requireFavorite = YES;
            requirePlace  = YES;
            
            if (imageCount > 0) {
                identifier = placeFavoriteWithImageCellIdentifier;
                requireImage = YES;
            }
        } else if (tweetForUpdating.isFavorited) {
            identifier = favoriteCellIdentifier;
            requireFavorite = YES;
            
            if (imageCount > 0) {
                identifier = favoriteWithImageCellIdentifier;
                requireImage = YES;
            }
        } else if (tweetForUpdating.place) {
            identifier = placeCellIdentifier;
            requirePlace = YES;
            if (imageCount > 0) {
                identifier = placeWithImageCellIdentifier;
                requireImage = YES;
            }
            
        }else {
            identifier = tweetCellIdentifier;
            if (imageCount > 0) {
                identifier = tweetWithImageCellIdentifier;
                requireImage = YES;
            }
        }
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    if (requireRetweet == NO) {
        [cell removeRetweetView];
    }
    if (requireFavorite == NO) {
        [cell removeFavoriteView];
    }
    if (requirePlace == NO) {
        [cell removePlaceNameView];
    }
    if (requireImage == NO) {
        [cell removeImageContainerView];
    }
    
    [self updateCell:cell tweet:tweetForUpdating AtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(MBTweetViewCell *)cell tweet:(MBTweet *)tweet AtIndexPath:(NSIndexPath *)indexPath
{
    cell.delegate = self;
    
    MBTweet *tweetAtIndexPath = tweet;
    if (tweetAtIndexPath == nil) { /* nil チェック. 必要ないかも */
        NSString *key = [self.dataSource objectAtIndex:indexPath.row];
        tweetAtIndexPath = [[MBTweetManager sharedInstance] storedTweetForKey:key];
        if (tweetAtIndexPath.tweetOfOriginInRetweet) {
            MBTweet *retweetedTweet = tweet.tweetOfOriginInRetweet;
            tweetAtIndexPath = retweetedTweet;
            if (cell.retweetView.superview) {
                cell.retweetView.attributedString = [MBTweetTextComposer attributedStringForTimelineRetweeter:tweet.tweetUser font:[UIFont systemFontOfSize:15.0f]];
                cell.retweetView.delegate = self;
            }
        }
    }
    
    MBUser *userAtIndexPath = tweetAtIndexPath.tweetUser;
    
    
    // favorite & geo
    cell.placeNameView.placeString = [MBTweetTextComposer attributedStringForTimelinePlace:tweetAtIndexPath.place font:[UIFont systemFontOfSize:15.0f]];
    
    // timeView
    NSString *timeIntervalString = [NSString timeMarginWithDate:tweetAtIndexPath.createdDate];
    [cell setDateString:[MBTweetTextComposer attributedStringForTimelineDate:timeIntervalString font:[UIFont systemFontOfSize:12.0f] screeName:userAtIndexPath.screenName tweetID:[tweetAtIndexPath.tweetID unsignedLongLongValue]]];
    cell.dateView.delegate = self;
    
    // charaScreenNameView
    [cell setCharaScreenString:[MBTweetTextComposer attributedStringForTimelineUser:tweetAtIndexPath.tweetUser charFont:[UIFont systemFontOfSize:15.0f] screenFont:[UIFont systemFontOfSize:14.0f]]];
    
    // tweetText
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.tweetTextView.lineSpace = LINE_SPACING;
    cell.tweetTextView.lineHeight = LINE_HEIGHT;
    cell.tweetTextView.paragraphSpace = PARAGRAPF_SPACING;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:tweetAtIndexPath tintColor:[self.navigationController.navigationBar tintColor]];
    cell.tweetTextView.delegate = self;
    
    // AvatorImageView
    cell.userIDStr = userAtIndexPath.userIDStr;
    cell.userID = userAtIndexPath.userID;
    cell.avatorImageView.delegate = self;
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedTimelineImageForUser:userAtIndexPath.userIDStr];
    if (!avatorImage) {
        cell.avatorImageView.image = [UIImage imageNamed:@"TimelineDefaultImage"];
        if (NO == tweetAtIndexPath.tweetUser.isDefaultProfileImage) {
            
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(globalQueue, ^{
                [MBImageDownloader downloadOriginImageWithURL:userAtIndexPath.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                    if (image) {
                        [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:userAtIndexPath.userIDStr];
                        CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                        UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:cell.avatorImageView.layer.cornerRadius];
                        [[MBImageCacher sharedInstance] storeTimelineImage:radiusImage forUserID:userAtIndexPath.userIDStr];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([cell.userIDStr isEqualToString:userAtIndexPath.userIDStr]) {
                                cell.avatorImageView.image = radiusImage;
                            }
                        });
                    }
                    
                }failedHandler:^(NSURLResponse *response, NSError *error){
                    
                }];
                
            });
            
        }
    } else {
        cell.avatorImageView.image = avatorImage;
    }
    
    // mediaImage
    NSInteger imageCounts = tweetAtIndexPath.entity.media.count;
    if (imageCounts > 0) {
        cell.imageContainerView.imageCount = imageCounts;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            int i = 0;
            for (MBMediaLink *mediaLink in tweetAtIndexPath.entity.media) {
                UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedCroppedMediaImageForMediaID:mediaLink.mediaIDStr];
                MBMediaImageView *mediaImageView = [cell.imageContainerView.imageViews objectAtIndex:i];
                mediaImageView.delegate = self;
                mediaImageView.mediaIDStr = mediaLink.mediaIDStr;
                mediaImageView.mediaHTTPURLString = mediaLink.originalURLHttpsText;
                
                if (mediaImage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        mediaImageView.image = mediaImage;
                    });
                    
                } else {
                    
                    [MBImageDownloader downloadMediaImageWithURL:mediaLink.originalURLHttpsText completionHandler:^(UIImage *image, NSData *imageData) {
                        if (image) {
                            [[MBImageCacher sharedInstance] storeMediaImage:image data:imageData forMediaID:mediaLink.mediaIDStr];
                            
                            CGSize mediaImageSize = CGSizeMake(mediaImageView.frame.size.width, mediaImageView.frame.size.height);
                            UIImage *croppedImage = [MBImageApplyer imageForMediaWithImage:image size:mediaImageSize];
                            [[MBImageCacher sharedInstance] storeCroppedMediaImage:croppedImage forMediaID:mediaLink.mediaIDStr];
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

- (void)updateTableViewDataSource:(NSArray *)addingData
{
    if (0 < [addingData count]) {
        __weak MBTimelineViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *update = [weakSelf.timelineManager addTweets:addingData];
            NSNumber *requiredGap = [update objectForKey:@"gaps"];
            NSNumber *requiredUpdateHeight = [update objectForKey:@"update"];
            
            NSArray *addedArray = weakSelf.timelineManager.tweets;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.dataSource = addedArray;
                
                CGFloat rowsHeight = 0;
                CGFloat currentDataSourceCount = [weakSelf.dataSource count];
                
                // tableView が一番上に有る時だけ高さを足すようにしてみる。 やめてみる
                if (0 != currentDataSourceCount && [requiredUpdateHeight boolValue]) {
                    rowsHeight = [weakSelf rowHeightForAddingData:addingData isGap:[requiredGap boolValue]];
                }
                
                CGPoint currentOffset = weakSelf.tableView.contentOffset;
                [weakSelf.tableView reloadData];
                currentOffset.y += rowsHeight;
                [weakSelf.tableView setContentOffset:currentOffset];

                
                // tableView の更新後に endRefreshing を呼ばないと、tableViewOffset が反映されない
                [weakSelf.refreshControl endRefreshing];
                weakSelf.enableBacking = YES;
                weakSelf.backsTimeline = NO;
                [weakSelf removeLoadingView];
            });
            
        });
        
    } else {
        [self.refreshControl endRefreshing];
        self.enableBacking = YES;
        [self removeLoadingView];
        if (self.backsTimeline) {
            self.enableBacking = NO;
            [self removeBackTimelineIndicatorView];
        }
        self.backsTimeline = NO;
    }
    
}

- (CGFloat)rowHeightForAddingData:(NSArray *)addingData isGap:(BOOL)isGap
{
    __block CGFloat height  = 0;
    
    MBTweetManager *tweetManager = [MBTweetManager sharedInstance];
    for (NSString *key in addingData) {
        MBTweet *tweet = [tweetManager storedTweetForKey:key];
        
        CGFloat heightForRow = [self calculateHeightTableView:self.tableView tweet:tweet key:key];
        
        height += heightForRow;
    }
    
    if (isGap) {
        height += 48;
    }

    return height;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (YES == [[segue identifier] isEqualToString:@"PostTweetIdentifier"]) {
        
    } else if ([[segue identifier] isEqualToString:@"DetailTweetIdentifier"]) {
        NSString *selectedID = self.dataSource[self.tableView.indexPathForSelectedRow.row];
        MBTweet *selectedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:selectedID];
        MBDetailTweetViewController *detailTweetViewController = [segue destinationViewController];
        [detailTweetViewController setTweet:selectedTweet];
        
    }
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedID = self.dataSource[indexPath.row];
    MBTweet *selectedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:selectedID];
    
    MBDetailTweetViewController *detailTweetViewController = [[MBDetailTweetViewController alloc] initWithNibName:@"MBTweetDetailView" bundle:nil];
    if (nil != selectedTweet.tweetOfOriginInRetweet) {
        [detailTweetViewController setRetweeter:selectedTweet.tweetUser];
        
        MBTweet *retweetedTweet = selectedTweet.tweetOfOriginInRetweet;
        selectedTweet = retweetedTweet;
    } else if (selectedTweet.isRetweeted) {
        MBUser *myUser = [[MBUserManager sharedInstance] storedUserForKey:[MBAccountManager sharedInstance].currentAccount.userID];
        [detailTweetViewController setRetweeter:myUser];
    }
    
    [detailTweetViewController setTweet:selectedTweet];
    [self.navigationController pushViewController:detailTweetViewController animated:YES];
}

#pragma mark -
#pragma mark ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float max = scrollView.contentInset.top + scrollView.contentInset.bottom + scrollView.contentSize.height - scrollView.bounds.size.height;
    float current = scrollView.contentOffset.y + self.topLayoutGuide.length;
    int intMax = max * 0.5;
    int intCurrent = current;
    if (intMax < intCurrent) {
        if (self.enableBacking && 0 != self.dataSource.count) {
            [self goBacksAtIndex:self.saveIndex];
        }
    }
}

#pragma mark -
#pragma mark MBTwitterAccesser Delegate
- (void)gotAccessTokenTwitterAccesser:(MBTwitterAccesser *)twitterAccesser
{
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if ([accountManager isSelectedAccount]) {
        return;
    }
    [[MBAccountManager sharedInstance] selectAccountAtIndex:0];
    [self refreshMyAccountUser];
}

#pragma mark AOuth_TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets
{
    if (requestType == MBTwitterStatusesShowSingleTweetRequest) {
        MBTweet *targetTweet = [tweets firstObject];
        NSNumber *tweetID = [targetTweet.currentUserRetweetedTweet numberForKey:@"id"];
        if (tweetID) {
            [self.aoAPICenter postDestroyTweetForTweetID:[tweetID unsignedLongLongValue]];
        }
        return;
    }
    
    if (requestType == MBTwitterStatusesDestroyTweetRequest) {
        MBTweet *tweet = [tweets firstObject];
        
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = (NSString *)obj;
            if ([key isEqualToString:tweet.tweetIDStr]) {
                NSIndexPath *targetIndex = [NSIndexPath indexPathForRow:idx inSection:0];
                
                [self.timelineManager removeTweetAtIndex:targetIndex.row];
                self.dataSource = self.timelineManager.tweets;
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[targetIndex] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                
                *stop = YES;
            }
        }];
        return;
    }
    
    [self updateTableViewDataSource:tweets];
}

#pragma mark MBPostTweetViewController Delegate
- (void)dismissPostTweetViewController:(MBPostTweetViewController *)controller animated:(BOOL)animated
{
    [self refreshAction];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MBAvatorImageView Delegate
- (void)imageViewDidClick:(MBAvatorImageView *)imageView userID:(NSNumber *)userID userIDStr:(NSString *)userIDStr
{
    //imageView.selected = YES;
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

#pragma mark MBMediaImageView Delegate
- (void)didTapImageView:(MBMediaImageView *)imageView mediaIDStr:(NSString *)mediaIDStr urlString:(NSString *)urlString touchedPoint:(CGPoint)touchedPoint rect:(CGRect)rect
{
    CGPoint convertedPointToTableView = [self.tableView convertPoint:touchedPoint fromView:imageView];
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    CGPoint convertedPointToSelfView = [self.view convertPoint:center fromView:imageView];
    
    NSIndexPath *selectedIndexpath = [self.tableView indexPathForRowAtPoint:convertedPointToTableView];
    NSString *selectedID = self.dataSource[selectedIndexpath.row];
    MBTweet *selectedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:selectedID];
    if (nil != selectedTweet.tweetOfOriginInRetweet) {
        MBTweet *retweetedTweet = selectedTweet.tweetOfOriginInRetweet;
        selectedTweet = retweetedTweet;
    }
    
    MBImageViewController *imageViewController = [[MBImageViewController alloc] init];
    [imageViewController setTweet:selectedTweet];
    imageViewController.delegate = self;
    imageViewController.transitioningDelegate = self;
    self.zoomTransitioning = [[MBZoomTransitioning alloc] initWithPoint:convertedPointToSelfView];
    
    UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:mediaIDStr];
    imageViewController.mediaImage = mediaImage;
    if (!mediaImage) {
        [imageViewController setMediaIDStr:mediaIDStr];
        [imageViewController setImageURLString:urlString];
    }
    
    [self presentViewController:imageViewController animated:YES completion:nil];
}

#pragma mark TweetTextViewCell Delegate
- (void)didLongPressTweetViewCell:(MBTweetViewCell *)cell atPoint:(CGPoint)touchPoint
{
    /*
    // set up UIMenuController
    [self becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:cell.frame inView:cell.superview];
    menuController.arrowDirection = UIMenuControllerArrowDefault;
    
    UIMenuItem *replyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Reply", nil) action:@selector(didPushReplyAction:)];
    
    menuController.menuItems = @[replyItem];
    [menuController update];
    [menuController setMenuVisible:YES animated:YES];
    
    cell.selected = YES;*/
    cell.selected = YES;
    CGRect cellFrame = cell.frame;
    cellFrame.origin = [self.view convertPoint:cellFrame.origin fromView:self.tableView];
    touchPoint = [self.view convertPoint:touchPoint toView:self.tableView];
    MBTimelineActionView *actionView = [[MBTimelineActionView alloc] initWithRect:cellFrame atPoint:touchPoint];
    actionView.delegate = self;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    [actionView setSelectedIndexPath: selectedIndexPath];
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *selectedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    if (nil != selectedTweet.tweetOfOriginInRetweet) {
        MBTweet *retweetedTweet = selectedTweet.tweetOfOriginInRetweet;
        selectedTweet = retweetedTweet;
    }
    
    [actionView setSelectedTweet:selectedTweet];
    
    [actionView showViews:YES animated:YES inView:self.navigationController.view];
    
}

- (void)dismissActionView:(MBTimelineActionView *)view
{
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:view.selectedIndexPath];
    [selectedCell setSelected:NO animated:YES];
}

- (void)didPushReplyButtonOnActionView:(MBTimelineActionView *)view
{    
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    if (tweet.tweetOfOriginInRetweet) {
        tweet = tweet.tweetOfOriginInRetweet;
    }
    
    MBPostTweetViewController *postTweetViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postTweetViewController.delegate = self;
    [postTweetViewController addReply:tweet.tweetID];
    [postTweetViewController setReferencedTweet:tweet];
    [postTweetViewController setScreenName:tweet.tweetUser.screenName];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postTweetViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
        [view showViews:NO animated:NO];
    }];
}

- (void)didPushRetweetButtonOnActionView:(MBTimelineActionView *)view
{
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    if (tweet.tweetOfOriginInRetweet) {
        tweet = tweet.tweetOfOriginInRetweet;
    }
    
    [self.aoAPICenter postRetweetForTweetID:[tweet.tweetID unsignedLongLongValue]];
    
}

- (void)didPushFavoriteButtonOnActionView:(MBTimelineActionView *)view
{
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    if (tweet.tweetOfOriginInRetweet) {
        tweet = tweet.tweetOfOriginInRetweet;
    }
    
    [self.aoAPICenter postFavoriteForTweetID:[tweet.tweetID unsignedLongLongValue]];
}

- (void)didPushCancelRetweetButtonOnActionView:(MBTimelineActionView *)view
{
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    MBTweet *targetTweet = tweet;
    if (tweet.tweetOfOriginInRetweet) {
        targetTweet = tweet.tweetOfOriginInRetweet;
    }
    
    if (targetTweet.currentUserRetweetedTweet) {
        NSNumber *tweetID = [targetTweet.currentUserRetweetedTweet numberForKey:@"id"];
        [self.aoAPICenter postDestroyTweetForTweetID:[tweetID unsignedLongLongValue]];
    } else {
        [self.aoAPICenter getTweet:[targetTweet.tweetID unsignedLongLongValue]];
    }
    
}

- (void)didPushCancelFavoriteButtonOnActionView:(MBTimelineActionView *)view
{
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    MBTweet *targetTweet = tweet;
    if (tweet.tweetOfOriginInRetweet) {
        targetTweet = tweet.tweetOfOriginInRetweet;
    }
    
    [self.aoAPICenter postDestroyFavoriteForTweetID:[targetTweet.tweetID unsignedLongLongValue]];
}

#pragma mark WebBrowsViewController Delegate
- (void)closeBrowsViewController:(MBWebBrowsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TweetTextView Delegate
- (void)tweetTextView:(MBTweetTextView *)textView clickOnLink:(MBLinkText *)linktext point:(CGPoint)touchePoint
{
    
    CGPoint convertedPointToTableView = [self.tableView convertPoint:touchePoint fromView:textView];
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
        
        NSIndexPath *selectedIndexpath = [self.tableView indexPathForRowAtPoint:convertedPointToTableView];
        NSString *selectedID = self.dataSource[selectedIndexpath.row];
        MBTweet *selectedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:selectedID];
        if (nil != selectedTweet.tweetOfOriginInRetweet) {
            MBTweet *retweetedTweet = selectedTweet.tweetOfOriginInRetweet;
            selectedTweet = retweetedTweet;
        }
        
        MBMediaLink *link = linktext.obj;
        
        MBImageViewController *imageViewController = [[MBImageViewController alloc] init];
        [imageViewController setImageURLString:link.originalURLHttpsText];
        [imageViewController setMediaIDStr:link.mediaIDStr];
        [imageViewController setTweet:selectedTweet];
        imageViewController.delegate = self;
        UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:link.mediaIDStr];
        imageViewController.mediaImage = mediaImage;
        
        imageViewController.transitioningDelegate = self;
        
        self.zoomTransitioning = [[MBZoomTransitioning alloc] initWithPoint:convertedPointToSelfView];
        [self presentViewController:imageViewController animated:YES completion:nil];
    }
    
}

#pragma mark retweetView Delegate
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
    return self.zoomTransitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.zoomTransitioning.isReverse = YES;
    return self.zoomTransitioning;
}

@end

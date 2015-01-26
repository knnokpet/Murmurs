//
//  MBTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"

#import "MBSearchViewController.h"
#import "MBTextCacher.h"

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
{
    CGFloat lineSpacing;
    CGFloat lineHeight;
    CGFloat paragraphSpacing;
    CGFloat tweetFontSize;
}

@property (nonatomic) MBTwitterAccesser *twitterAccesser;

@property (nonatomic) MBZoomTransitioning *zoomTransitioning;

@property (nonatomic, assign) BOOL backsTimeline;

@property (nonatomic) CGFloat beginDraggingOffsetY;
@property (nonatomic) CGFloat endScrollingOffsetY;

@end

@implementation MBTimelineViewController

#pragma mark -
#pragma mark Initialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeConstantNumber];
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
    self.requireUpdatingDatasource = NO;
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
    
    [self configureRefrechControll];
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
        [self requestAccessToAccount];
    }
    
}

/* for iOS 8 */
- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutManager:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self configureBackTimelineIndicatorView];
    [self configureLoadingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
    
    [self updateVisibleCells];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
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
- (void)requestAccessToAccount
{
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    [accountManager requestAccessToAccountWithCompletionHandler:^ (BOOL granted, NSArray *accounts, NSError *error) {
        
        if (!granted || accounts.count == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                MBAuthorizationViewController *authorizationViewController = [[MBAuthorizationViewController alloc] initWithNibName:@"AuthorizationView" bundle:nil];
                authorizationViewController.delegate = self;
                self.twitterAccesser = [[MBTwitterAccesser alloc] init];
                self.twitterAccesser.delegate = self;
                authorizationViewController.twitterAccesser = [[MBTwitterAccesser alloc] init];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authorizationViewController];
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            });
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

- (void)configureLoadingView
{
    if (!self.loadingView.superview && self.dataSource.count == 0) {
        CGRect loadingnRect = self.view.bounds;
        /* iOS 8 以降は、SizeClass が導入されたせいか、self.view.bounds がスクリーンサイズに適応されるのが遅い。
         追記:
         というか、もとから viewDidLoad ではUI要素はロードされていない。クラスがロードされただけで、作成されているわけてはない。*/
        _loadingView = [[MBLoadingView alloc] initWithFrame:loadingnRect];
        [self.view insertSubview:self.loadingView aboveSubview:self.tableView];
    }
}

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

- (void)configureNoResultView
{
    if (!self.resultView && self.dataSource.count == 0) {
        _resultView = [[MBNoResultView alloc] initWithFrame:self.view.bounds];
        self.resultView.noResultText = NSLocalizedString(@"No Tweets...", nil);
        [self.resultView.reloadButton addTarget:self action:@selector(didPushReloadButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:self.resultView aboveSubview:self.tableView];
    }
}

- (void)removeNoResultView
{
    if (!self.resultView.superview) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.resultView.alpha = 0;
    }completion:^(BOOL finished) {
        [self.resultView removeFromSuperview];
        _resultView = nil;
    }];
}

- (void)configureBackTimelineIndicatorView
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    CGFloat bottomMargin = 4.0f;
    CGFloat indicatorHeight = indicatorView.frame.size.height;
    UIView *indicatorContanerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, indicatorHeight + bottomMargin * 2)];
    [indicatorContanerView addSubview:indicatorView];
    indicatorView.center = indicatorContanerView.center;
    self.tableView.tableFooterView = indicatorContanerView;
}

- (void)removeBackTimelineIndicatorView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
}

- (void)configureRefrechControll
{
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)updateVisibleCells
{
    for (MBTweetViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[MBGapedTweetViewCell class]]) {
            continue;
        }
        
        if (cell.avatorImageView.isSelected) {
            [cell.avatorImageView setIsSelected:NO  withAnimated:YES];
        }
        
        NSIndexPath *updatingIndexPath = [self.tableView indexPathForCell:cell];
        MBTweet *visibleTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[self.dataSource objectAtIndex:updatingIndexPath.row]];
        
        [self updateCell:cell tweet:visibleTweet AtIndexPath:updatingIndexPath];
    }
}

- (void)updateVisibleCellImages
{
    for (MBTweetViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[MBGapedTweetViewCell class]]) {
            continue;
        }
        
        NSIndexPath *updatingIndexPath = [self.tableView indexPathForCell:cell];
        MBTweet *visibleTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[self.dataSource objectAtIndex:updatingIndexPath.row]];
        MBTweet *updateTweet = visibleTweet;
        if (visibleTweet.tweetOfOriginInRetweet) {
            updateTweet = visibleTweet.tweetOfOriginInRetweet;
        }
        [self updateAvatorImageForCell:cell user:updateTweet.tweetUser];
        [self updateMediaImageForCell:cell tweet:updateTweet];
    }
}

- (void)updateVisibleCellsAndCellHeight
{
    [self.tableView beginUpdates];
    [self updateVisibleCells];
    [self.tableView endUpdates];
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
            [self.timelineManager addSaveIndex];
        } else {
            [self.timelineManager stopLoadingSavedTweets];
            [self backTimeline];
        }
    }else if (0 < index) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *savedTweets = [self savedTweetsAtIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (0 < [savedTweets count]) {
                    if (self.tableView.dragging || self.tableView.decelerating) {
                        self.requireUpdatingDatasource = YES;
                        self.updatingDatasource = savedTweets;
                    } else {
                        [self updateTableViewDataSource:savedTweets];
                    }
                    [self.timelineManager addSaveIndex];
                } else {
                    [self.timelineManager stopLoadingSavedTweets];
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
            button.enabled = NO;
            
            self.timelineManager.currentLoadingGapedTweet = [self.dataSource objectAtIndex:button.tag];
            
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

- (void)didPushReloadButton
{
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount] ) {
        [self goBacksAtIndex:0];
    } else {
        [self requestAccessToAccount];
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
    
    if (self.requireUpdatingDatasource) {
        [self updateTableViewDataSource:self.updatingDatasource];
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
/* for iOS 8 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[MBGapedTweet class]]) {
        MBGapedTweetViewCell *gapedCell = [self.tableView dequeueReusableCellWithIdentifier:gapedCellIdentifier];
        [self updateGapedCell:gapedCell atIndexPath:indexPath];
                
        return gapedCell;
    }
    
    NSString *cellIdentifier = @"Cell";
    MBTweetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MBTweetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBTweet *tweetAtIndex = [[MBTweetManager sharedInstance] storedTweetForKey:key];
    [self updateCell:cell tweet:tweetAtIndex AtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(MBTweetViewCell *)cell tweet:(MBTweet *)tweet AtIndexPath:(NSIndexPath *)indexPath
{
    cell.delegate = self;
    
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
    
    /* nil チェック. 必要ないかも。あれ、ないと自身が retweet したつぶやきが表示されないぞ*/
    if (tweetForUpdating == nil) {
        NSString *key = [self.dataSource objectAtIndex:indexPath.row];
        tweetForUpdating = [[MBTweetManager sharedInstance] storedTweetForKey:key];
        if (tweetForUpdating.tweetOfOriginInRetweet) {
            MBTweet *retweetedTweet = tweet.tweetOfOriginInRetweet;
            tweetForUpdating = retweetedTweet;
            if (cell.retweeterView.superview) {
                NSAttributedString *retweeterName = [MBTweetTextComposer attributedStringForTimelineRetweeter:tweetForUpdating.tweetUser font:[UIFont systemFontOfSize:15.0f]];
                MBUser *linkUser = tweetForUpdating.tweetUser;
                if (tweetForUpdating.isRetweeted) {
                    retweeterName = [MBTweetTextComposer attributedStringByRetweetedMeForTimelineWithfont:[UIFont systemFontOfSize:15.0f]];
                    linkUser = [[MBUserManager sharedInstance] storedUserForKey:[[MBAccountManager sharedInstance]currentAccount].userID];
                }
                [cell.retweeterView setRetweeterString:retweeterName];
                [cell.retweeterView setUserLink:[[MBMentionUserLink alloc]initWithUserID:linkUser.userID IDStr:linkUser.userIDStr screenName:linkUser.screenName]];
                cell.retweeterView.delegate = self;
            }
        }
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
        if ([self isDownloadingImageWithUrlString:user.urlHTTPSAtProfileImage]) {
            return;
        }
        
        __weak MBTimelineViewController *weakSelf = self;
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
    __weak MBTimelineViewController *weakSelf = self;
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
        
        mediaImageView.delegate = weakSelf;
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

- (BOOL)isDownloadingImageWithUrlString:(NSString *)urlString
{
    BOOL isDownloading = [[MBImageCacher sharedInstance] isDownloadingImageWithUrlStr:urlString];
    
    return isDownloading;
}

- (void)updateGapedCell:(MBGapedTweetViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBGapedTweet *gapedTweet = [self.dataSource objectAtIndex:indexPath.row];
    [cell.gapButton addTarget:self action:@selector(didPushGapButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.gapButton.tag = gapedTweet.index;
    cell.gapButton.enabled = YES;
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
        
        MBTweet *retweetedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:selectedTweet.tweetOfOriginInRetweet.tweetIDStr];
        if (!retweetedTweet) {
            retweetedTweet = selectedTweet.tweetOfOriginInRetweet;
        }
        selectedTweet = retweetedTweet;
    } else if (selectedTweet.isRetweeted) {
        MBUser *myUser = [[MBUserManager sharedInstance] storedUserForKey:[MBAccountManager sharedInstance].currentAccount.userID];
        [detailTweetViewController setRetweeter:myUser];
    }
    
    [detailTweetViewController setTweet:selectedTweet];
    
    self.navigationItem.backBarButtonItem = [self backButtonItem];
    [self.navigationController pushViewController:detailTweetViewController animated:YES];
}

- (UIBarButtonItem *)backButtonItem
{
    return nil;
}

#pragma mark
- (void)updateTableViewDataSource:(NSArray *)addingData
{
    if (0 < [addingData count]) {
        
        __weak MBTimelineViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *update = [weakSelf.timelineManager addTweets:addingData];
            BOOL requiredGap = [[update objectForKey:@"gaps"] boolValue];
            BOOL requiredUpdateHeight = [[update objectForKey:@"update"] boolValue];
            BOOL isAddingGap = [[update objectForKey:@"addingGap"] boolValue];
            BOOL requireGapUpdating = [self requireAddingUpdateForGap];
            NSArray *addingTweets = [update objectForKey:@"addingData"];
            
            NSArray *addedDatasource = weakSelf.timelineManager.tweets;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat currentDataSourceCount = [weakSelf.dataSource count];
                weakSelf.dataSource = addedDatasource;
                
                CGFloat rowsHeight = 0;
                
                
                
                if (0 != currentDataSourceCount && isAddingGap && requireGapUpdating) {
                    rowsHeight = [weakSelf rowHeightForAddingData:addingTweets isGap:requiredGap isAddingGap:isAddingGap];
                    
                } else if (0 != currentDataSourceCount && isAddingGap && !requireGapUpdating) {
                    
                }else if (0 != currentDataSourceCount && requiredUpdateHeight) {
                    rowsHeight = [weakSelf rowHeightForAddingData:addingTweets isGap:requiredGap isAddingGap:isAddingGap];
                }
                
                CGPoint currentOffset = weakSelf.tableView.contentOffset;
                [weakSelf.tableView reloadData];
                currentOffset.y += rowsHeight;
                [weakSelf.tableView setContentOffset:currentOffset];
                
                
                // tableView の更新後に endRefreshing を呼ばないと、tableViewOffset が反映されない
                [weakSelf.refreshControl endRefreshing];
                if (weakSelf.backsTimeline) {
                    weakSelf.enableBacking = YES;
                }
                
                weakSelf.timelineManager.currentLoadingGapedTweet = nil;
                weakSelf.backsTimeline = NO;
                weakSelf.requireUpdatingDatasource = NO;
                [weakSelf removeLoadingView];
                [weakSelf removeNoResultView];
                
            });
            
        });
        
    } else {
        [self.refreshControl endRefreshing];
        if (self.timelineManager.currentLoadingGapedTweet) {
            
            NSInteger index = self.timelineManager.gaps.count - 1;
            for (MBGapedTweet *gapedTweet in [self.timelineManager.gaps reverseObjectEnumerator]) {
                if (self.timelineManager.currentLoadingGapedTweet.index == gapedTweet.index) {
                    break;
                }
                gapedTweet.index = gapedTweet.index - 1;
                index--;
            }
            [self.timelineManager.gaps removeObjectAtIndex:index];
            NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:self.timelineManager.currentLoadingGapedTweet.index inSection:0];
            self.dataSource = self.timelineManager.tweets;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            self.timelineManager.currentLoadingGapedTweet = nil;
        }
        
        if (self.dataSource.count == 0) {
            [self configureNoResultView];
        } else {
            [self removeNoResultView];
        }
        
        self.enableBacking = YES;
        [self removeLoadingView];
        self.backsTimeline = NO;
        self.requireUpdatingDatasource = NO;
    }
    
}

- (CGFloat)rowHeightForAddingData:(NSArray *)addingData isGap:(BOOL)isGap isAddingGap:(BOOL)isAdding
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
    
    if (isAdding) {
        height -= 48;
    }
    
    return height;
}

- (BOOL)requireAddingUpdateForGap
{
    BOOL require = NO;
    NSInteger margin = self.beginDraggingOffsetY - self.endScrollingOffsetY;
    if (margin > 0) {
        require = YES;
    }
    
    return require;
}

#pragma mark -
#pragma mark ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.timelineManager.currentOffset = self.tableView.contentOffset;
    
    if (scrollView.isDecelerating &&(long)scrollView.contentOffset.y % 50 == 0) {
        [self updateVisibleCellImages];
    }
    
    [self timelineScrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.beginDraggingOffsetY = scrollView.contentOffset.y;
    
    [self timelineScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.requireUpdatingDatasource) {
        NSArray *adding = self.updatingDatasource.copy;
        self.updatingDatasource = nil;
        [self updateTableViewDataSource:adding];
        return;
    }
    
    [self updateVisibleCells]; // reDraw images
    self.endScrollingOffsetY = scrollView.contentOffset.y;
    [self fireFetchingByContentOffsetOfScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        
        if (self.requireUpdatingDatasource) {
            NSArray *adding = self.updatingDatasource.copy;
            self.updatingDatasource = nil;
            [self updateTableViewDataSource:adding];
            return;
        }
        
        [self updateVisibleCells]; // reDraw images
        [self fireFetchingByContentOffsetOfScrollView:scrollView];
    }
    
    self.endScrollingOffsetY = scrollView.contentOffset.y;
    [self timelineScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)fireFetchingByContentOffsetOfScrollView:(UIScrollView *)scrollView
{
    float max = scrollView.contentInset.top + scrollView.contentInset.bottom + scrollView.contentSize.height - scrollView.bounds.size.height;
    float current = scrollView.contentOffset.y + self.topLayoutGuide.length;
    int intMax = max * 0.8;
    int intCurrent = current;
    if (intCurrent > intMax) {
        if (self.enableBacking && 0 != self.dataSource.count) {
            [self goBacksAtIndex:self.timelineManager.saveIndex];
        } else {
            
        }
    }
}

#pragma mark 
- (void)timelineScrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)timelineScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)timelineScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
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
    
    [self configureTimelineManager];
}

#pragma mark MBAuthorizationViewController Delegate
- (void)dismissAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

- (void)succeedAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if ([accountManager isSelectedAccount]) {
        return;
    }
    [[MBAccountManager sharedInstance] selectAccountAtIndex:0];
    [self refreshMyAccountUser];
    
    [controller dismissViewControllerAnimated:YES completion:nil];
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
        
    } else if (requestType == MBTwitterStatusesDestroyTweetRequest) {
        MBTweet *tweet = [tweets firstObject];
        /* 自信のアカウントによるつぶやきなら削除。それ以外はビュー更新 */
        __block BOOL requireReload = YES;
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = (NSString *)obj;
            if ([key isEqualToString:tweet.tweetIDStr]) {
                NSIndexPath *targetIndex = [NSIndexPath indexPathForRow:idx inSection:0];
                
                [self.timelineManager removeTweetAtIndex:targetIndex.row];
                self.dataSource = self.timelineManager.tweets;
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[targetIndex] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                requireReload = NO;
                
                *stop = YES;
            }
        }];
        if (requireReload) {
            [self updateVisibleCellsAndCellHeight];
        }
        
        return;
        
    } else if (requestType == MBTwitterStatusesUpdateRequest) {
        MBTweet *postedTweet = [tweets firstObject];
        if (postedTweet) {
            [self refreshAction];
        }
        return;
    } else if (requestType == MBTwitterStatusesRetweetsOfTweetRequest) {
        [self updateVisibleCellsAndCellHeight];
        return;
        
    } else if (requestType == MBTwitterFavoritesCreateRequest) {
        [self updateVisibleCellsAndCellHeight];
        return;
        
    } else if (requestType == MBTwitterFavoritesDestroyRequest) {
        [self updateVisibleCellsAndCellHeight];
        return;
        
    }
    
    if (self.tableView.dragging || self.tableView.decelerating) {
        self.requireUpdatingDatasource = YES;
        self.updatingDatasource = tweets;
    } else{
        [self updateTableViewDataSource:tweets];
    }
    
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center error:(NSError *)error
{
    [self showErrorViewWithErrorText:error.localizedDescription];
    
    [self.refreshControl endRefreshing];
    self.enableBacking = YES;
    [self configureNoResultView];
    [self removeLoadingView];
    self.backsTimeline = NO;
    self.requireUpdatingDatasource = NO;
    if (error.code == 88) { /* rate limit */
        self.enableBacking = NO;
        [self removeBackTimelineIndicatorView];
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
    MBTweet *tweetAtIndex = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    MBTweet *selectedTweet = tweetAtIndex;
    if (tweetAtIndex.tweetOfOriginInRetweet) {
        selectedTweet = tweetAtIndex.tweetOfOriginInRetweet;
    }
    
    [actionView setSelectedTweet:tweetAtIndex];
    
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
    MBTweet *targetTweet = tweet;
    if (tweet.tweetOfOriginInRetweet) {
        targetTweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweet.tweetOfOriginInRetweet.tweetIDStr];
        if (!targetTweet) {
            targetTweet = tweet.tweetOfOriginInRetweet;
        }
    }
    [targetTweet setIsRetweeted:YES];
    
    [self.aoAPICenter postRetweetForTweetID:[targetTweet.tweetID unsignedLongLongValue]];
    
}

- (void)didPushFavoriteButtonOnActionView:(MBTimelineActionView *)view
{
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *targetedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    
    [self.aoAPICenter postFavoriteForTweetID:[targetedTweet.tweetID unsignedLongLongValue]];
}

- (void)didPushCancelRetweetButtonOnActionView:(MBTimelineActionView *)view
{
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    MBTweet *targetTweet = tweet;
    if (tweet.tweetOfOriginInRetweet) {
        targetTweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweet.tweetOfOriginInRetweet.tweetIDStr];
        if (!targetTweet) {
            targetTweet = tweet.tweetOfOriginInRetweet;
        }
    }
    [targetTweet setIsRetweeted:NO];
    
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
    
    [self.aoAPICenter postDestroyFavoriteForTweetID:[tweet.tweetID unsignedLongLongValue]];
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
        MBHashTagLink *hashtagLink = (MBHashTagLink *)linktext.obj;
        MBSearchViewController *searchViewController = [[MBSearchViewController alloc] init];
        [searchViewController setSearchingTweetQuery:[NSString stringWithFormat:@"#%@", hashtagLink.displayText]];
        [self.navigationController pushViewController:searchViewController animated:YES];
        
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

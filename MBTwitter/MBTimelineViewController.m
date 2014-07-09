//
//  MBTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"


static NSString *tweetCellIdentifier = @"TweetTableViewCellIdentifier";
static NSString *gapedCellIdentifier = @"GapedTweetTableViewCellIdentifier";
static NSString *retweetCellIdentifier = @"RetweetTableViewCellIdentifier";

@interface MBTimelineViewController ()

@property (nonatomic) MBTwitterAccesser *twitterAccesser;

@property (nonatomic) MBZoomTransitioning *zoomTransitioning;

@property (nonatomic) NSInteger saveIndex;
@property (nonatomic, assign) BOOL enableAdding;

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
    // アカウントの変更時に Home, Reply の timelineManager を保持するため
    _timelineManager = [[MBTimeLineManager alloc] init];
    self.dataSource = self.timelineManager.tweets;
}

- (void)commonConfigureModel
{
    [self configureTimelineManager];
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    self.aoAPICenter.delegate = self;
    self.enableAdding = NO;
    
    self.saveIndex = 0;
}

#pragma mark -
#pragma mark View
- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *cellNib = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:tweetCellIdentifier];
    UINib *gapedCellNib = [UINib nibWithNibName:@"GapedTweetTableViewCell" bundle:nil];
    [self.tableView registerNib:gapedCellNib forCellReuseIdentifier:gapedCellIdentifier];
    UINib *retweetCel = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:retweetCel forCellReuseIdentifier:retweetCellIdentifier];
    
    // refreshControl
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // loadingView
    _loadingView = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.loadingView aboveSubview:self.tableView];
    
}

- (void)commonConfigureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushLeftBarButtonItem)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(didPushRightBarButtonItem)];
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
        [UIView animateWithDuration:1.0f animations:^{
            [self.loadingView setHidden:YES];
        }completion:^(BOOL finished){
            [self.loadingView removeFromSuperview];
            _loadingView = nil;
        }];
    }
}

#pragma mark save & load Tweets
- (void)saveTimeline
{
    NSArray *saveTweets = self.dataSource;
    [[MBTweetManager sharedInstance] saveTimeline:saveTweets];
}

- (void)goBacksAtIndex:(NSInteger )index
{
    self.enableAdding = NO;
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
    self.enableAdding = NO;
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
    
    NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:tweet tintColor:[self.navigationController.navigationBar tintColor]];
    
    
    NSInteger textViewWidth = tableViewForCalculate.bounds.size.width - (64.0f + 8.0f);
    CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(textViewWidth, CGFLOAT_MAX) lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:FONT_SIZE]];
    
    CGFloat tweetViewSpace = 34.0f;
    CGFloat bottomHeight = 0.0f;
    if (nil != tweet.tweetOfOriginInRetweet) {
        /*というか、つぶやきの最終行に改行があるのでは？*/
        bottomHeight = 18.0f + /*あると Retweet 時に大きく幅が開いてしまう*/ 4.0f + 4.0f;
    } else {
        bottomHeight = 12.0f;
    }
    CGFloat customCellHeight = textRect.size.height + tweetViewSpace + bottomHeight;
    
    CGFloat defaultHeight = 48 + 12 + 12;
    
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
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[MBGapedTweet class]]) {
        return 120;
    }
    
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:key];
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
    if (nil != tweetAtIndex.tweetOfOriginInRetweet) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:retweetCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier forIndexPath:indexPath];
        [cell removeRetweetView];
    }
    
    //MBTweetViewCell *cell= [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier forIndexPath:indexPath];
    
    //[self updateCell:cell AtIndexPath:indexPath];
    [self updateCell:cell tweet:tweetAtIndex AtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(MBTweetViewCell *)cell tweet:(MBTweet *)tweet AtIndexPath:(NSIndexPath *)indexPath
{
    cell.delegate = self;
    
    MBTweet *tweetAtIndexPath = tweet;
    if (tweetAtIndexPath == nil) {
        NSString *key = [self.dataSource objectAtIndex:indexPath.row];
        tweetAtIndexPath = [[MBTweetManager sharedInstance] storedTweetForKey:key];
    }
    
    cell.retweetView.attributedString = [[NSAttributedString alloc] initWithString:@""];
    if (nil != tweetAtIndexPath.tweetOfOriginInRetweet) {
        MBTweet *retweetedTweet = tweetAtIndexPath.tweetOfOriginInRetweet;
        NSString *retweetText = NSLocalizedString(@"retweeted by ", nil);
        NSString *textWithUser = [NSString stringWithFormat:@"%@%@", retweetText, tweetAtIndexPath.tweetUser.characterName];
        cell.retweetView.attributedString = [MBTweetTextComposer attributedStringForTimelineDate:textWithUser font:[UIFont systemFontOfSize:12.0f] screeName:retweetedTweet.tweetUser.screenName tweetID:[tweetAtIndexPath.tweetID unsignedLongLongValue]];
        
        tweetAtIndexPath = retweetedTweet;
    }
    
    MBUser *userAtIndexPath = tweetAtIndexPath.tweetUser;
    
    NSString *timeIntervalString = [NSString timeMarginWithDate:tweetAtIndexPath.createdDate];
    [cell setDateString:[MBTweetTextComposer attributedStringForTimelineDate:timeIntervalString font:[UIFont systemFontOfSize:12.0f] screeName:userAtIndexPath.screenName tweetID:[tweetAtIndexPath.tweetID unsignedLongLongValue]]];
    
    [cell setCharacterName:tweetAtIndexPath.tweetUser.characterName];
    [cell setScreenName:tweetAtIndexPath.tweetUser.screenName];
    
    
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.tweetTextView.lineSpace = LINE_SPACING;
    cell.tweetTextView.lineHeight = LINE_HEIGHT;
    cell.tweetTextView.paragraphSpace = PARAGRAPF_SPACING;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:tweetAtIndexPath tintColor:[self.navigationController.navigationBar tintColor]];
    cell.tweetTextView.delegate = self;
    
    
    cell.userIDStr = userAtIndexPath.userIDStr;
    cell.avatorImageView.userID = userAtIndexPath.userID;
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedTimelineImageForUser:userAtIndexPath.userIDStr];
    if (!avatorImage) {
        
        if (NO == tweetAtIndexPath.tweetUser.isDefaultProfileImage) {
            
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(globalQueue, ^{
                [MBImageDownloader downloadBigImageWithURL:userAtIndexPath.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                    if (image) {
                        [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:userAtIndexPath.userIDStr];
                        CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                        UIImage *radiusImage = [MBImageApplyer imageForTwitter:image byScallingToFillSize:imageSize radius:cell.avatorImageView.layer.cornerRadius];
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
    
    
    cell.avatorImageView.delegate = self;
}

- (void)updateTableViewDataSource:(NSArray *)addingData
{
    if (0 < [addingData count]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *update = [self.timelineManager addTweets:addingData];
            NSNumber *requiredGap = [update objectForKey:@"gaps"];
            NSNumber *requiredUpdateHeight = [update objectForKey:@"update"];
            
            NSArray *visibleCells = [self.tableView visibleCells];
            NSIndexPath *topVisibleIndexPath = [self.tableView indexPathForCell:[visibleCells firstObject]];
            
            CGFloat rowsHeight = 0;
            CGFloat currentDataSourceCount = [self.dataSource count];
            
            // tableView が一番上に有る時だけ高さを足すようにしてみる。
            if (0 != currentDataSourceCount && 0 == topVisibleIndexPath.row) {
                if (YES == [requiredUpdateHeight boolValue]) {
                    rowsHeight = [self rowHeightForAddingData:addingData isGap:[requiredGap boolValue]];
                }
            }
            NSArray *addedArray = self.timelineManager.tweets;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataSource = addedArray;
                
                CGPoint currentOffset = self.tableView.contentOffset;
                [self.tableView reloadData];
                currentOffset.y += rowsHeight;
                [self.tableView setContentOffset:currentOffset];

                
                // tableView の更新後に endRefreshing を呼ばないと、tableViewOffset が反映されない
                [self.refreshControl endRefreshing];
                self.enableAdding = YES;
                
                [self removeLoadingView];
            });
            
        });
        
    } else {
        [self.refreshControl endRefreshing];
        self.enableAdding = YES;
        [self removeLoadingView];
    }
}

- (CGFloat)rowHeightForAddingData:(NSArray *)addingData isGap:(BOOL)isGap
{
    __block CGFloat height  = 0;
    
    MBTweetManager *tweetManager = [MBTweetManager sharedInstance];
    [addingData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *key = (NSString *)obj;
            MBTweet *tweet = [tweetManager storedTweetForKey:key];
            
            CGFloat heightForRow = [self calculateHeightTableView:self.tableView tweet:tweet key:key];

            height += heightForRow;
        }
    }];
    
    if (isGap) {
        height += 120;
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
    if (nil != selectedTweet.tweetOfOriginInRetweet) {
        MBTweet *retweetedTweet = selectedTweet.tweetOfOriginInRetweet;
        selectedTweet = retweetedTweet;
    }
    MBDetailTweetViewController *detailTweetViewController = [[MBDetailTweetViewController alloc] initWithNibName:@"MBTweetDetailView" bundle:nil];
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
        if (self.enableAdding && 0 != self.dataSource.count) {
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
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
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
    [actionView setSelectedIndexPath:[self.tableView indexPathForCell:cell]];
    
    [actionView showViews:YES animated:YES inView:self.tabBarController.view];
    
}

- (void)dismissActionView:(MBTimelineActionView *)view
{
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:view.selectedIndexPath];
    [selectedCell setSelected:NO animated:YES];
}

- (void)didPushReplyButtonOnActionView:(MBTimelineActionView *)view
{
    NSLog(@"rep");
    
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    
    MBPostTweetViewController *postTweetViewController = [[MBPostTweetViewController alloc] initWithNibName:@"PostTweetView" bundle:nil];
    postTweetViewController.delegate = self;
    [postTweetViewController addReply:tweet.tweetID];
    [postTweetViewController setReferencedTweet:tweet];
    [postTweetViewController setScreenName:tweet.tweetUser.screenName];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postTweetViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didPushRetweetButtonOnActionView:(MBTimelineActionView *)view
{
    NSLog(@"ret");
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    
    [self.aoAPICenter postRetweetForTweetID:[tweet.tweetID unsignedLongLongValue]];
}

- (void)didPushFavoriteButtonOnActionView:(MBTimelineActionView *)view
{
    NSLog(@"fav");
    NSIndexPath *selectedIndexPath = view.selectedIndexPath;
    NSString *tweetKey = [self.dataSource objectAtIndex:selectedIndexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:tweetKey];
    
    [self.aoAPICenter postFavoriteForTweetID:[tweet.tweetID unsignedLongLongValue]];
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
        UINavigationController *imageNavigationController = [[UINavigationController alloc] initWithRootViewController:imageViewController];
        imageNavigationController.transitioningDelegate = self;
        
        self.zoomTransitioning = [[MBZoomTransitioning alloc] initWithPoint:convertedPointToSelfView];
        [self presentViewController:imageNavigationController animated:YES completion:nil];
    }
    
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

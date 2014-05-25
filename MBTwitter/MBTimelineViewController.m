//
//  MBTimelineViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"



@interface MBTimelineViewController ()
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

- (void)commonConfigureModel
{
    _timelineManager = [[MBTimeLineManager alloc] init];
    self.dataSource = self.timelineManager.tweets;
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
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"TweetTableViewCellIdentifier"];
    UINib *gapedCellNib = [UINib nibWithNibName:@"GapedTweetTableViewCell" bundle:nil];
    [self.tableView registerNib:gapedCellNib forCellReuseIdentifier:@"GapedTweetTableViewCellIdentifier"];
    
    // refreshControl
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
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
    
    
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount] ) {
        [self goBacksAtIndex:0];
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
#pragma mark save & load Tweets
- (void)saveTimeline
{
    NSArray *saveTweets = self.dataSource;
    [[MBTweetManager sharedInstance] saveTimeline:saveTweets];
}

- (void)goBacksAtIndex:(NSInteger )index
{
    
    if (0 <= index) {
        self.enableAdding = NO;
        NSArray *savedTweets = [self savedTweetsAtIndex:index];
        if (0 < [savedTweets count]) {
            [self updateTableViewDataSource:savedTweets];
            self.saveIndex++;
        } else {
            self.saveIndex = -1;
            [self backTimeline];
        }
    } else {
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



- (void)refreshAction
{
    NSInteger since = 0 + 1;
    
    MBTweet *sinceTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.dataSource[since]];
    [self goForwardTimelineSinceID:[sinceTweet.tweetID unsignedLongLongValue]];
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    // override
}

#pragma mark -
#pragma mark UITableView DataSource & Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[MBGapedTweet class]]) {
        return 120;
    }
    
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:key];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:tweet.tweetText];
    
    NSInteger textViewWidth = tableView.bounds.size.width - (64 + 8);
    CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(textViewWidth, CGFLOAT_MAX) lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:FONT_SIZE]];
    
    CGFloat tweetViewSpace = 28.0f;
    CGFloat bottomHeight = 0.0f;
    if (nil != tweet.tweetOfOriginInRetweet) {
        bottomHeight = 18.0f + 8.0f + 8.0f;
    } else {
        bottomHeight = 10.0f;
    }
    CGFloat customCellHeight = textRect.size.height + tweetViewSpace + bottomHeight;
    
    CGFloat defaultHeight = 48 + 10 + 10;
    
    return MAX(defaultHeight, customCellHeight);
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
    static NSString *tweetCellIdentifier = @"TweetTableViewCellIdentifier";
    static NSString *gapedCellIdentifier = @"GapedTweetTableViewCellIdentifier";
    
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[MBGapedTweet class]]) {
        MBGapedTweet *gapedTweet = [self.dataSource objectAtIndex:indexPath.row];
        MBGapedTweetViewCell *gapedCell = [self.tableView dequeueReusableCellWithIdentifier:gapedCellIdentifier];
        [gapedCell.gapButton addTarget:self action:@selector(didPushGapButton:) forControlEvents:UIControlEventTouchUpInside];
        gapedCell.gapButton.tag = gapedTweet.index;
        NSLog(@"gape cell");
        return gapedCell;
    }
    
    MBTweetViewCell *cell= [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier forIndexPath:indexPath];
    
    [self updateCell:cell AtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(MBTweetViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBTweet *tweetAtIndexPath = [[MBTweetManager sharedInstance] storedTweetForKey:key];
    [cell setNameRetweeted:@""];
    if (nil != tweetAtIndexPath.tweetOfOriginInRetweet) {
        MBTweet *retweetedTweet = tweetAtIndexPath.tweetOfOriginInRetweet;
        [cell setNameRetweeted:tweetAtIndexPath.tweetUser.characterName];
        tweetAtIndexPath = retweetedTweet;
    }
    [cell applyConstraints];
    
    MBUser *userAtIndexPath = tweetAtIndexPath.tweetUser;
    
    cell.chacacterNameLabel.text = tweetAtIndexPath.tweetUser.characterName;
    [cell setScreenName:tweetAtIndexPath.tweetUser.screenName];
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.tweetTextView.lineSpace = LINE_SPACING;
    cell.tweetTextView.lineHeight = LINE_HEIGHT;
    cell.tweetTextView.paragraphSpace = PARAGRAPF_SPACING;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:tweetAtIndexPath tintColor:[self.navigationController.navigationBar tintColor]];
    cell.tweetTextView.delegate = self;

    cell.userIDStr = userAtIndexPath.userIDStr;
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:userAtIndexPath.userIDStr];
    if (!avatorImage) {
        if (NO == tweetAtIndexPath.tweetUser.isDefaultProfileImage) {
            
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(globalQueue, ^{
                [MBImageDownloader downloadBigImageWithURL:userAtIndexPath.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                    if (image) {
                        [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:userAtIndexPath.userIDStr];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([cell.userIDStr isEqualToString:userAtIndexPath.userIDStr]) {
                                cell.avatorImageView.image = image;
                            }
                        });
                    }
                    
                }failedHandler:^(NSURLResponse *response, NSError *error){
                    
                }];
                
            });
            
        }
    }
    
    cell.avatorImageView.image = avatorImage;
    cell.avatorImageView.userID = userAtIndexPath.userID;
    cell.avatorImageView.delegate = self;
}

- (void)updateTableViewDataSource:(NSArray *)addingData
{
    if (0 < [addingData count]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *update = [self.timelineManager addTweets:addingData];
            NSIndexSet *indexSet = [update objectForKey:@"update"];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:200];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPaths addObject:indexPath];
            }];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataSource = self.timelineManager.tweets;
                
                CGFloat rowsHeight = 0;
                NSIndexPath *firstIndexPath = [indexPaths firstObject];
                if (0 == firstIndexPath.row) {
                    rowsHeight = [self rowHeightForAddingData:indexPaths];
                }
                
                CGPoint currentOffset = self.tableView.contentOffset;
                [self.tableView reloadData];
                currentOffset.y += rowsHeight;
                if (currentOffset.y > self.tableView.contentSize.height) {
                    currentOffset.y = 0;
                }
                self.tableView.contentOffset = currentOffset;
                [self.refreshControl endRefreshing];
                self.enableAdding = YES;
            });
            
        });
        
    } else {
        [self.refreshControl endRefreshing];
        self.enableAdding = YES;
    }
}

- (CGFloat)rowHeightForAddingData:(NSArray *)addingData
{
    CGFloat height  = 0;
    for (NSIndexPath *indexPath in addingData) {
        height += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
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
    int intMax = max * 0.9;
    int intCurrent = current;
    if (intMax < intCurrent) {
        if (self.enableAdding) {
            [self goBacksAtIndex:self.saveIndex];
        }
    }
}

#pragma mark -
#pragma mark AOuth_TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
    [self updateTableViewDataSource:tweets];
}

#pragma mark MBAvatorImageView Delegate
- (void)imageViewDidClick:(MBAvatorImageView *)imageView userID:(NSNumber *)userID userIDStr:(NSString *)userIDStr
{
    MBUser *selectedUser = [[MBUserManager sharedInstance] storedUserForKey:userIDStr];
    MBDetailUserViewController *userViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
    [userViewController setUser:selectedUser];
    if (nil == selectedUser) {
        [userViewController setUserID:userID];
    }
    [self.navigationController pushViewController:userViewController animated:YES];
}

#pragma mark WebBrowsViewController Delegate
- (void)closeBrowsViewController:(MBWebBrowsViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TweetTextView Delegate
- (void)tweetTextView:(MBTweetTextView *)textView clickOnLink:(MBLinkText *)linktext
{
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
    }
    
}

@end

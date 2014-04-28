//
//  MBSecondViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSecondViewController.h"
#import "MBDetailTweetViewController.h"

#import "MBTweetViewCell.h"
#import "MBGapedTweetViewCell.h"
#import "MBTweetTextView.h"

#import "MBTimeLineManager.h"
#import "MBTweetManager.h"
#import "MBTweet.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBUser.h"
#import "MBGapedTweet.h"

#import "MBTweetTextComposer.h"


#define LINE_SPACING 4.0f
#define LINE_HEIGHT 0.0f
#define PARAGRAPF_SPACING 0.0f
#define FONT_SIZE 17.0f

@interface MBSecondViewController () <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) MBTimeLineManager *timelineManager;

// View
@property (nonatomic, readonly) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *timelineButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic) NSArray *dataSource;


@end

@implementation MBSecondViewController

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
#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *cellNib = [UINib nibWithNibName:@"TweetTavbleViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"TweetTableViewCellIdentifier"];
    UINib *gapedCellNib = [UINib nibWithNibName:@"GapedTweetTableViewCell" bundle:nil];
    [self.tableView registerNib:gapedCellNib forCellReuseIdentifier:@"GapedTweetTableViewCellIdentifier"];
    
    // refreshControl
    _refreshControl = [[UIRefreshControl alloc] init];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Pull To Refresh", nil) attributes:nil];
    [refreshString addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor]} range:NSMakeRange(0, [refreshString length])];
    self.refreshControl.attributedTitle = refreshString;
    [self.refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    _timelineManager = [[MBTimeLineManager alloc] init];
    self.dataSource = self.timelineManager.tweets;
    
    //[[MBTweetManager sharedInstance] deleteAllSavedTweets];
    
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount] ) {
        self.title = [[MBAccountManager sharedInstance] currentAccount].screenName;
        _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        self.aoAPICenter.delegate = self;
        //[_aoAPICenter getHomeTimeLineSinceID:0 maxID:0];
        NSArray * savedTweets = [[MBTweetManager sharedInstance] savedTweetsAtIndex:0];
        if (0 < [savedTweets count]) {
            [self updateTableViewDataSource:savedTweets];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Action
- (IBAction)didPushTimelineButton:(id)sender {
    /*
    NSString *oldestIDStr = [self.hogeDataSource lastObject];
    MBTweet *oldestTweet = [[MBTweetManager sharedInstance] storedTweetForKey:oldestIDStr];
    NSNumber *oldestTweetID = oldestTweet.tweetID;
    unsigned long long requiredID = [oldestTweetID unsignedLongLongValue] - 1;
    [_aoAPICenter getBackHomeTimeLineMaxID:requiredID];

    
    NSString *sinceStr = self.tweets[1];
    MBTweet *sinceTweet = [[MBTweetManager sharedInstance] storedTweetForKey:sinceStr];
    unsigned long long sinceID = [sinceTweet.tweetID unsignedLongLongValue];
    
    NSString *maxIDStr = [self.latestTweets lastObject];
    MBTweet *maxTweet = [[MBTweetManager sharedInstance] storedTweetForKey:maxIDStr];
    unsigned long long maxID = [maxTweet.tweetID unsignedLongLongValue] - 1;
    [self.aoAPICenter getForwardHomeTimeLineSinceID:sinceID maxID:maxID];*/
}

- (IBAction)didPushSaveButton:(id)sender {
    
    NSArray *saveTweets = self.dataSource;
    [[MBTweetManager sharedInstance] saveWithTweets:saveTweets];
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
            [self.aoAPICenter getForwardHomeTimeLineSinceID:sinceID maxID:maxID];
        }
    }
}

#pragma mark RefreshControll
- (void)refreshAction
{
    NSInteger since = 0 + 1;
    
    MBTweet *sinceTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.dataSource[since]];
    [self.aoAPICenter getForwardHomeTimeLineSinceID:[sinceTweet.tweetID unsignedLongLongValue] maxID:0];
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

    NSInteger textViewWidth = self.tableView.frame.size.width - (8 + 46 + 8 + 8);
    CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(textViewWidth, 1000) lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:FONT_SIZE]];
    
    CGFloat customCellHeight = textRect.size.height + 28;

    return MAX(tableView.rowHeight, customCellHeight);
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
    
    MBTweetViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
    
    [self updateCell:cell AtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(MBTweetViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBTweet *tweetAtIndexPath = [[MBTweetManager sharedInstance] storedTweetForKey:key];
    MBUser *userAtIndexPath = tweetAtIndexPath.tweetUser;
    cell.screenNameLabel.text = tweetAtIndexPath.tweetUser.characterName;
    cell.characterNameLabel.text = tweetAtIndexPath.tweetUser.screenName;
    NSLog(@"tweet = %@", tweetAtIndexPath.tweetText);
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.tweetTextView.lineSpace = LINE_SPACING;
    cell.tweetTextView.lineHeight = LINE_HEIGHT;
    cell.tweetTextView.paragraphSpace = PARAGRAPF_SPACING;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:tweetAtIndexPath];//[[NSAttributedString alloc] initWithString:tweetAtIndexPath.tweetText];
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:userAtIndexPath.userIDStr];
    if (!avatorImage) {
        if (NO == tweetAtIndexPath.tweetUser.isDefaultProfileImage) {

            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(globalQueue, ^{
                
                [MBImageDownloader downloadImageWithURL:userAtIndexPath.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:userAtIndexPath.userIDStr];
                    
                }failedHandler:^(NSURLResponse *response, NSError *error) {
                    
                }];

            });
            
        }
    }
    
    cell.iconImageView.image = avatorImage;
}

- (void)updateTableViewDataSource:(NSArray *)addingData
{
    if (0 == [addingData count]) {
    } else {
        NSLog(@"before update = %d", [self.dataSource count]);
        NSDictionary *update = [self.timelineManager addTweets:addingData];
        self.dataSource = self.timelineManager.tweets;
        NSLog(@"after update = %d", [self.dataSource count]);
        
        [self.tableView beginUpdates];
        NSIndexSet *indexSet = [update objectForKey:@"update"];
        if (nil != indexSet) {
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:200];
            [indexSet enumerateIndexesUsingBlock:^ (NSUInteger idx, BOOL *stop) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPaths addObject:indexPath];
            }];
            NSLog(@"insert rows = %d", [indexPaths count]);
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        NSIndexPath *indexPath = [update objectForKey:@"remove"];
        if (nil != indexPath) {
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self.tableView endUpdates];
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (NSComparisonResult)compareTweet:(MBTweet *)aTweet tweet:(MBTweet *)bTweet
{
    NSComparisonResult result = [aTweet.tweetID compare:bTweet.tweetID];
    return result;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (YES == [[segue identifier] isEqualToString:@"PostTweetIdentifier"]) {
        
    } else if ([[segue identifier] isEqualToString:@"DetailTweetIdentifier"]) {
        NSArray *selectedDatasource = self.dataSource[self.tableView.indexPathForSelectedRow.section];
        NSString *selectedID = selectedDatasource[self.tableView.indexPathForSelectedRow.row];
        MBTweet *selectedTweet = [[MBTweetManager sharedInstance] storedTweetForKey:selectedID];
        MBDetailTweetViewController *detailTweetViewController = [segue destinationViewController];
        [detailTweetViewController setTweet:selectedTweet];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark AOuth_TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
    [self updateTableViewDataSource:tweets];
}


@end

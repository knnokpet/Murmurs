//
//  MBSecondViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSecondViewController.h"
#import "MBTweetManager.h"
#import "MBTweet.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBUser.h"


@interface MBSecondViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *timelineButton;

@property (nonatomic) NSMutableArray *hogeDataSource;

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    self.hogeDataSource = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (YES == [[MBAccountManager sharedInstance] isSelectedAccount] ) {
        self.title = [[MBAccountManager sharedInstance] currentAccount].screenName;
        _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        self.aoAPICenter.delegate = self;
        [_aoAPICenter getHomeTimeLineSinceID:0 maxID:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Action
- (IBAction)didPushTimelineButton:(id)sender {
    NSString *oldestIDStr = [self.hogeDataSource lastObject];
    MBTweet *oldestTweet = [[MBTweetManager sharedInstance] storedTweetForKey:oldestIDStr];
    NSNumber *oldestTweetID = oldestTweet.tweetID;
    unsigned long long requiredID = [oldestTweetID unsignedLongLongValue] - 1;
    [_aoAPICenter getBackHomeTimeLineMaxID:requiredID];
}


#pragma mark -
#pragma mark UITableView DataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hogeDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self updateCell:cell AtIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    MBTweet *tweetAtIndexPath = [[MBTweetManager sharedInstance] storedTweetForKey:[self.hogeDataSource objectAtIndex:indexPath.row]];
    MBUser *userAtIndexPath = tweetAtIndexPath.tweetUser;
    cell.textLabel.text = tweetAtIndexPath.tweetText;
    
    
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
    
    cell.imageView.image = avatorImage;
}

- (void)updateTableViewDataSource:(NSArray *)addingData
{
    MBTweetManager *tweetManager = [MBTweetManager sharedInstance];
    MBTweet *oldestAddingTweet = [tweetManager storedTweetForKey:[addingData lastObject]];
    MBTweet *latestExisingTweet = [tweetManager storedTweetForKey:[self.hogeDataSource firstObject]];
    
    BOOL isAddedLatest = [self isAddedLatestWithOldestAddingTweet:oldestAddingTweet LatestExistingtweet:latestExisingTweet];
    NSLog(@"isAdded = %hhd", isAddedLatest);
    if (isAddedLatest) {
        ;
    } else {
        [self.hogeDataSource addObjectsFromArray:addingData];
    }
    [self.tableView reloadData];
    NSLog(@"hoge = %lu", (unsigned long)[self.hogeDataSource count]);
}

- (BOOL)isAddedLatestWithOldestAddingTweet:(MBTweet *)addingTweet LatestExistingtweet:(MBTweet *)existingTweet
{
    if (nil == existingTweet) {
        return NO;
    }
    
    BOOL isAddedLatest = (NSOrderedAscending == [existingTweet.tweetID compare:addingTweet.tweetID]) ? YES : NO;
    return isAddedLatest;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (YES == [[segue identifier] isEqualToString:@"PostTweetIdentifier"]) {
        
    }
}

#pragma mark -
#pragma mark AOuth_TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
    [self updateTableViewDataSource:tweets];
}


@end

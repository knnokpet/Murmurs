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
#import "UIImage+Resize.h"

#import "MBTweetTextComposer.h"
#import "MBTweet.h"
#import "MBUser.h"

#import "MBMagnifierView.h"
#import "MBMagnifierRangeView.h"

#import "MBDetailTweetUserTableViewCell.h"
#import "MBDetailTweetTextTableViewCell.h"
#import "MBDetailTweetActionsTableViewCell.h"

#define LINE_SPACING 4.0f
#define LINE_HEIGHT 0.0f
#define PARAGRAPF_SPACING 0.0f
#define FONT_SIZE 20.0f

static NSString *userCellIdentifier = @"UserCellIdentifier";
static NSString *tweetCellIdentifier = @"TweetCellIdentifier";
static NSString *actionsCellIdentifier = @"ActionsCellIdentifier";

@interface MBDetailTweetViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

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

#pragma mark -
#pragma mark View
- (void)configureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
}

- (void)configureViews
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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

#pragma mark -
#pragma mark Delegate
#pragma mark TableView Delegate Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 48.0f;
    if (0 == indexPath.row) {
        height = 48.0f + (10.0f + 10.f);
    } else if (1 == indexPath.row) {
        
        NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
        
        NSInteger viewWidth = self.tableView.bounds.size.width - (20.0f + 20.0f);
        CGRect textRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(viewWidth, CGFLOAT_MAX) lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:FONT_SIZE]];

        height = textRect.size.height + (20.0f ) + (8.0f + 18.f + 8.0f);
    } else {
        height = 48.0f;
    }
    
    
    
    return  height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3; // default
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (0 == indexPath.row) {
        MBDetailTweetUserTableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:userCellIdentifier];
        [self updateUserCell:userCell];
        cell = userCell;
    } else if (1 == indexPath.row) {
        MBDetailTweetTextTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
        [self updateTweetViewCell:textCell];
        cell = textCell;
    } else if (2 == indexPath.row) {
        MBDetailTweetActionsTableViewCell *actionsCell = [self.tableView dequeueReusableCellWithIdentifier:actionsCellIdentifier];
        [self updateActionsCell:actionsCell];
        cell = actionsCell;
    }
    
    return cell;
}

- (void)updateUserCell:(MBDetailTweetUserTableViewCell *)cell
{
    MBUser *user = self.tweet.tweetUser;
    cell.characterNameLabel.text = user.characterName;
    cell.screenNameLabel.text = user.characterName;
    [cell setScreenName:user.screenName];
    
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
                        
                        image = [image imageByScallingToFillSize:CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height)];
                        [[MBImageCacher sharedInstance] storeTimelineImage:image forUserID:user.userIDStr];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.avatorImageView.image = image;
                        });
                    }
                    
                }failedHandler:^(NSURLResponse *response, NSError *error){
                    
                }];
                
            });
            
        }
    }
    cell.avatorImageView.image = avatorImage;
}

- (void)updateTweetViewCell:(MBDetailTweetTextTableViewCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.tweetTextView.lineSpace = LINE_SPACING;
    cell.tweetTextView.lineHeight = LINE_HEIGHT;
    cell.tweetTextView.paragraphSpace = PARAGRAPF_SPACING;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
    //cell.tweetTextView.isSelectable = YES; ルーペを実装できないため。
    cell.tweetTextView.delegate = self;
    
    cell.dateView.attributedString = [MBTweetTextComposer attributedStringForDetailTweetDate:[self.tweet.createdDate description] font:[UIFont systemFontOfSize:12.0f] screeName:self.tweet.tweetUser.screenName tweetID:[self.tweet.tweetID unsignedLongLongValue]];
}

- (void)updateActionsCell:(MBDetailTweetActionsTableViewCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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

#pragma mark AOuth_APICenterDelegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
    MBTweet *parsedTweet = [tweets firstObject];
    [self setTweet:parsedTweet];
    [self.tableView reloadData];
    NSLog(@"retweet or destroyRetweet  parsed Text = %@", parsedTweet.tweetText);
}

#pragma mark TweetTextViewDelegate
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

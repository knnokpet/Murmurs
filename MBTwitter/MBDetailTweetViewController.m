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

#import "MBTweetTextComposer.h"
#import "MBTweet.h"
#import "MBUser.h"

#import "MBTweetTextView.h"

#define LINE_SPACING 4.0f
#define LINE_HEIGHT 0.0f
#define PARAGRAPF_SPACING 0.0f
#define FONT_SIZE 20.0f

@interface MBDetailTweetViewController () <UIActionSheetDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

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
    MBUser *user = self.tweet.tweetUser;
    self.avatorImageView.image = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:user.userIDStr];
    self.characterNameLabel.text = user.characterName;
    
    // tweetTextView
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.tweet.tweetText];
    CGSize textSize = CGSizeMake(self.view.bounds.size.width - (20 + 20), CGFLOAT_MAX);
    CGRect frame = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:textSize lineSpace:LINE_SPACING font:[UIFont systemFontOfSize:LINE_HEIGHT]];
    CGFloat height = frame.size.height;
    NSLog(@"height = %f", height);
    CGRect textFrame = self.tweetTextView.frame;
    textFrame.size.height = height;
    self.tweetTextView.frame = textFrame;
    self.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE];
    self.tweetTextView.lineHeight = LINE_HEIGHT;
    self.tweetTextView.lineSpace = LINE_SPACING;
    self.tweetTextView.paragraphSpace = PARAGRAPF_SPACING;
    self.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:self.tweet tintColor:[self.navigationController.navigationBar tintColor]];
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
- (IBAction)didPushFavoriteButton:(id)sender {
    [self.aoAPICenter postFavoriteForTweetID:[self.tweet.tweetID unsignedLongLongValue]];
}
- (IBAction)didPushUnFavoriteButton:(id)sender {
    [self.aoAPICenter postDestroyFavoriteForTweetID:[self.tweet.tweetID unsignedLongLongValue]];
}

#pragma mark -
#pragma mark Delegate
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
    NSLog(@"retweet or destroyRetweet  parsed Text = %@", parsedTweet.tweetText);
}


@end

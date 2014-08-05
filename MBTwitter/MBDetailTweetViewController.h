//
//  MBDetailTweetViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPostTweetViewController.h"
#import "MBImageViewController.h"
#import "MBAOuth_TwitterAPICenter.h"
#import "MBWebBrowsViewController.h"
#import "MBTweetTextView.h"
#import "MBMediaImageView.h"

@class MBTweet;
@class MBUser;
@interface MBDetailTweetViewController : UIViewController <UIViewControllerTransitioningDelegate, MBPostTweetViewControllerDelegate, MBAOuth_TwitterAPICenterDelegate, MBTweetTextViewDelegate, MBWebBrowsViewControllerDelegate, MBMediaImageViewDelegate, MBImageViewControllerDelegate>

@property (nonatomic, readonly) MBTweet *tweet;
@property (nonatomic, readonly) MBUser *retweeter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)setTweet:(MBTweet *)tweet;
- (void)setRetweeter:(MBUser *)retweeter;

@end

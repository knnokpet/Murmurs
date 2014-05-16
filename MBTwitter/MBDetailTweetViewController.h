//
//  MBDetailTweetViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPostTweetViewController.h"
#import "MBAOuth_TwitterAPICenter.h"

@class MBTweet;
@class MBTweetTextView;
@interface MBDetailTweetViewController : UIViewController <MBPostTweetViewControllerDelegate, MBAOuth_TwitterAPICenterDelegate>

@property (nonatomic, readonly) MBTweet *tweet;
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UIButton *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *characterNameLabel;
@property (weak, nonatomic) IBOutlet MBTweetTextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *unFavoriteButton;

- (void)setTweet:(MBTweet *)tweet;

@end

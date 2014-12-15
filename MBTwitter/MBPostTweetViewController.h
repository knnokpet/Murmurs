//
//  MBPostTweetViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBAOuth_TwitterAPICenter.h"

@protocol MBPostTweetViewControllerDelegate;
@class MBTweet;
@interface MBPostTweetViewController : UIViewController <CLLocationManagerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, MBAOuth_TwitterAPICenterDelegate>

@property (nonatomic, weak) id <MBPostTweetViewControllerDelegate> delegate;
@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) MBTweet *referencedTweet;

@property (nonatomic) UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewRightSpaceConstraint;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
- (void)setText:(NSString *)text;

- (void)addReply:(NSNumber *)replyID;
- (void)setScreenName:(NSString *)screenName;
- (void)setRetweetWithComent:(NSString *)retweetedText tweetedUser:(NSString *)screenName;
- (void)setReferencedTweet:(MBTweet *)referencedTweet;

@end



@protocol MBPostTweetViewControllerDelegate <NSObject>

- (void)dismissPostTweetViewController:(MBPostTweetViewController *)controller animated:(BOOL)animated;
- (void)sendTweetPostTweetViewController:(MBPostTweetViewController *)controller tweetText:(NSString *)tweetText replys:(NSArray *)replys place:(NSDictionary *)place media:(NSArray *)media;

@optional
- (void)sendTweetPostTweetViewController:(MBPostTweetViewController *)controller; /* unused */

@end
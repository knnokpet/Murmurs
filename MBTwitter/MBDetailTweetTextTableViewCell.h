//
//  MBDetailTweetTextTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBTimelineImageContainerView;
@class MBTweetTextView;
@interface MBDetailTweetTextTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MBTweetTextView *tweetTextView;
@property (weak, nonatomic) IBOutlet MBTweetTextView *dateView;
@property (weak, nonatomic) IBOutlet MBTweetTextView *retweetView;
@property (weak, nonatomic) IBOutlet MBTimelineImageContainerView *imageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *geoLabel;

- (void)removeRetweetView;
- (void)removeImageContainerView;

@end

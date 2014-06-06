//
//  MBDetailUserViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"

@class MBTweetTextView;
@class MBUser;
@interface MBDetailUserViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate, UIScrollViewDelegate>

@property (nonatomic, readonly) MBUser *user;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, readonly) NSNumber *userID;

- (void)setUser:(MBUser *)user;
- (void)setUserID:(NSNumber *)userID;

@end

//
//  MBHomeTimelineViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/02.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"
#import "MBMyAccountsViewController.h"
#import "MBPostTweetViewController.h"

@interface MBHomeTimelineViewController : MBTimelineViewController <MBMyAccountsViewControlerDelegate, MBPostTweetViewControllerDelegate>

@end

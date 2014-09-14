//
//  MBMyProfileViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailUserViewController.h"
#import "MBMyAccountsViewController.h"
#import "MBPostTweetViewController.h"
#import "MBSearchedTweetViewController.h"

@interface MBMyProfileViewController : MBDetailUserViewController <MBMyAccountsViewControlerDelegate, MBPostTweetViewControllerDelegate>

@end

//
//  MBViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMyAccountsViewController.h"
#import "MBPostTweetViewController.h"

@class MBAOuth_TwitterAPICenter;
@interface MBViewController : UIViewController <MBMyAccountsViewControlerDelegate, MBPostTweetViewControllerDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@end

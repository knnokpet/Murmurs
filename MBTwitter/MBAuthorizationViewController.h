//
//  MBAuthorizationViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBTwitterAccesser.h"

@interface MBAuthorizationViewController : UIViewController

@property (nonatomic) MBTwitterAccesser *twitterAccesser;

@end

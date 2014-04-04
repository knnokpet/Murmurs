//
//  MBMyAccountsViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAuthorizationViewController.h"

@protocol MBMyAccountsViewControlerDelegate;

@class MBTwitterAccesser;
@interface MBMyAccountsViewController : UIViewController <MBAuthorizationViewControllerDelegate>

@property (nonatomic) MBTwitterAccesser *twitterAccessor;
@property (nonatomic, weak) id <MBMyAccountsViewControlerDelegate> delegate;

@end


@protocol MBMyAccountsViewControlerDelegate <NSObject>

- (void)popAccountsViewController:(MBMyAccountsViewController *)controller animated:(BOOL)animated;

@end
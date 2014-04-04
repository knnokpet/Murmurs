//
//  MBAuthorizationViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBTwitterAccesser.h"

@protocol MBAuthorizationViewControllerDelegate;

@interface MBAuthorizationViewController : UIViewController <MBTwitterAccesserDelegate>

@property (nonatomic) MBTwitterAccesser *twitterAccesser;
@property (nonatomic, weak) id <MBAuthorizationViewControllerDelegate> delegate;

@end


@protocol MBAuthorizationViewControllerDelegate <NSObject>

- (void)dismissAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated;

@end
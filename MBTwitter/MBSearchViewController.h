//
//  MBSearchViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBSearchedTweetViewController.h"
#import "MBSearchedUsersViewController.h"
#import "MBPostTweetViewController.h"
#import "MBAOuth_TwitterAPICenter.h"
#import "MBSegmentedContainerView.h"

@interface MBSearchViewController : UIViewController <UISearchBarDelegate, MBAOuth_TwitterAPICenterDelegate, MBSearchedTweetViewControllerDelegate, MBSearchedUsersViewControllerDelegate, MBPostTweetViewControllerDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) NSString *searchingTweetQuery;

@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic) UIViewController *currentController;
@property (nonatomic, readonly) MBSearchedTweetViewController *tweetViewController;
@property (nonatomic, readonly) MBSearchedUsersViewController *usersViewController;
@property (nonatomic, readonly) MBSegmentedContainerView *segmentedContainerView;
@property (nonatomic, readonly) UISegmentedControl *segmentedControl;

- (void)setSearchingTweetQuery:(NSString *)searchingTweetQuery;

@end

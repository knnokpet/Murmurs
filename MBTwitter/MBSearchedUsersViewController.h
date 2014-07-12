//
//  MBSearchedUsersViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsersViewController.h"


@protocol MBSearchedUsersViewControllerDelegate;
@interface MBSearchedUsersViewController : MBUsersViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id <MBSearchedUsersViewControllerDelegate> delegate;

@property (nonatomic, readonly) NSString *query;
- (void)setQuery:(NSString *)query;

@end


@protocol MBSearchedUsersViewControllerDelegate <NSObject>

- (void)scrollViewInSearchedUsersViewControllerBeginDragging:(MBSearchedUsersViewController *)controller;

@end
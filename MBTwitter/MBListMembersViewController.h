//
//  MBListMembersViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsersViewController.h"

@class MBList;
@class MBUser;
@protocol MBListMembersViewControllerDelegate;
@protocol MBListMembersViewControllerScrollViewDelegate;
@interface MBListMembersViewController : MBUsersViewController

@property (nonatomic, weak) id < MBListMembersViewControllerDelegate > delegate;
@property (nonatomic, weak) id < MBListMembersViewControllerScrollViewDelegate > scrollDelegate;

@property (nonatomic, readonly) MBList *list;
@property (nonatomic) NSArray *reservedRemovingUsers;

- (void)setList:(MBList *)list;

@end



@protocol MBListMembersViewControllerScrollViewDelegate <NSObject>

- (void)listMembersScrollViewDidScroll:(MBListMembersViewController *)controller scrollView:(UIScrollView *)scrollView;
- (void)listMembersScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)listMembersScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

@protocol MBListMembersViewControllerDelegate <NSObject>

- (void)removeMemberListMembersViewController:(MBListMembersViewController *)controller user:(MBUser *)user;

@end
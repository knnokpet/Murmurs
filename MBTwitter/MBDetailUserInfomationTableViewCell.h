//
//  MBDetailUserInfomationTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBUser;
@class MBProfileAvatorView;
@class MBProfileDesciptionView;
@class MBProfileInfomationView;
@interface MBDetailUserInfomationTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, readonly) MBUser *user;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, readonly) MBProfileAvatorView *profileAvatorView;
@property (nonatomic, readonly) MBProfileDesciptionView *profileDescriptionView;
@property (nonatomic, readonly) MBProfileInfomationView *profileInformationView;

- (void)setUser:(MBUser *)user;

- (void)updateCellContentsView;

@end

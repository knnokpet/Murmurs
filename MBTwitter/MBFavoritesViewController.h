//
//  MBFavoritesViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"

@interface MBFavoritesViewController : MBTimelineViewController

@property (nonatomic, readonly) MBUser *user;

- (void)setUser:(MBUser *)user;

@end

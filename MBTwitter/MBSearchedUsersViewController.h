//
//  MBSearchedUsersViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsersViewController.h"

@interface MBSearchedUsersViewController : MBUsersViewController

@property (nonatomic, readonly) NSString *query;
- (void)setQuery:(NSString *)query;

@end

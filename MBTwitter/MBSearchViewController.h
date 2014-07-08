//
//  MBSearchViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"

@interface MBSearchViewController : UIViewController <UISearchBarDelegate, MBAOuth_TwitterAPICenterDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@end

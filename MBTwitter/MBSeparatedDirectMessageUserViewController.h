//
//  MBSeparatedDirectMessageUserViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"

@interface MBSeparatedDirectMessageUserViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

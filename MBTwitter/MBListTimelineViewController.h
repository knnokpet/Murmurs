//
//  MBListTimelineViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"

@class MBList;
@interface MBListTimelineViewController : MBTimelineViewController

@property (nonatomic, readonly) MBList *list;

- (void)setList:(MBList *)list;

@end

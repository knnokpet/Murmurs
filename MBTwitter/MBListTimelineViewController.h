//
//  MBListTimelineViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineViewController.h"

@class MBList;
@protocol MBListTimelineViewControllerDelegate;
@interface MBListTimelineViewController : MBTimelineViewController <UIScrollViewDelegate>

@property (nonatomic, readonly) MBList *list;
@property (nonatomic, weak) id <MBListTimelineViewControllerDelegate> delegate;

- (void)setList:(MBList *)list;

@end


@protocol MBListTimelineViewControllerDelegate <NSObject>

- (void)scrollTimelineViewController:(MBListTimelineViewController *)controller;

@end
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
@interface MBListTimelineViewController : MBTimelineViewController

@property (nonatomic, weak) id <MBListTimelineViewControllerDelegate> delegate;

@property (nonatomic, readonly) MBList *list;

- (void)setList:(MBList *)list;

@end



@protocol MBListTimelineViewControllerDelegate <NSObject>

- (void)listTimelineScrollViewDidScroll:(MBListTimelineViewController *)controller scrollView:(UIScrollView *)scrollView;
- (void)listTimelineScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)listTimelineScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end
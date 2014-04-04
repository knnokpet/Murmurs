//
//  MBPostTweetViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBPostTweetViewControllerDelegate;
@class MBAOuth_TwitterAPICenter;
@interface MBPostTweetViewController : UIViewController

@property (nonatomic, weak) id <MBPostTweetViewControllerDelegate> delegate;
@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@end


@protocol MBPostTweetViewControllerDelegate <NSObject>

- (void)dismissPostTweetViewController:(MBPostTweetViewController *)controller animated:(BOOL)animated;

@end
//
//  MBSelectionView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBSelectionGrabber, MBTweetTextView;
@interface MBSelectionView : UIView

- (instancetype)initWithFrame:(CGRect)frame tweetTextView:(MBTweetTextView *)textView;

@property (nonatomic, weak) MBTweetTextView *tweetTextView;

@property (nonatomic) MBSelectionGrabber *startGrabber;
@property (nonatomic) MBSelectionGrabber *endGrabber;

@property (nonatomic) UILongPressGestureRecognizer *selectionGestureRecognizer;
@property (nonatomic) UIPanGestureRecognizer *startGrabberGestureRecognizer;
@property (nonatomic) UIPanGestureRecognizer *endGrabberGestureRecognizer;

@property (nonatomic) CGRect startFrame;
@property (nonatomic) CGRect endFrame;

- (void)updateGrabbers;

- (void)showViews;
- (void)hideViews;

@end

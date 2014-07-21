//
//  MBImageViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/06.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"

@class MBTweet;
@class MBAvatorImageView;
@protocol MBImageViewControllerDelegate;
@interface MBImageViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MBAOuth_TwitterAPICenterDelegate>

@property (nonatomic, weak) id <MBImageViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubletapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;



@property (weak, nonatomic) IBOutlet UIView *tweetContainerView;
@property (weak, nonatomic) IBOutlet MBAvatorImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *characterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@property (nonatomic, readonly) NSString *mediaIDStr;
@property (nonatomic, readonly) NSString *imageURLString;
@property (nonatomic, readonly) MBTweet *tweet;
@property (nonatomic, readonly) UIImage *mediaImage;


- (void)setMediaIDStr:(NSString *)mediaIDStr;
- (void)setImageURLString:(NSString *)imageURLString;
- (void)setTweet:(MBTweet *)tweet;

@end


@protocol MBImageViewControllerDelegate <NSObject>

- (void)dismissImageViewController:(MBImageViewController *)controller;

@end
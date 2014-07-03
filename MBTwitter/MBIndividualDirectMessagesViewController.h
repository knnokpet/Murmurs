//
//  MBIndividualDirectMessagesViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"
#import "MBMessageReceiverViewController.h"

@protocol MBIndividualDirectMessagesViewControllerDelegate;
@class MBUserIDManager;
@class MBUser;
@interface MBIndividualDirectMessagesViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate, MBMessageReceiverViewControllerDelegate,  UITextViewDelegate, UIScrollViewDelegate>


@property (nonatomic, weak) id < MBIndividualDirectMessagesViewControllerDelegate > delegate;

@property (nonatomic, readonly) MBUserIDManager *userIDManager;
@property (nonatomic, readonly) MBUser *partner;
@property (nonatomic, readonly) NSMutableArray *conversation;
@property (nonatomic, readonly) NSMutableDictionary *nonSendMessages;

@property (weak, nonatomic) IBOutlet UIToolbar *receiverToolbar;
@property (weak, nonatomic) IBOutlet UITextField *receiverTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiverToolbarConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *containedView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@property (nonatomic, readonly, assign) BOOL isEditing;

- (void)setUserIDManager:(MBUserIDManager *)userIDManager;
- (void)setIsEditing:(BOOL)isEditing;
- (void)setPartner:(MBUser *)partner;
- (void)setConversation:(NSMutableArray *)conversation;

@end



@protocol MBIndividualDirectMessagesViewControllerDelegate <NSObject>

- (void)sendMessageIndividualDirectMessagesViewController:(MBIndividualDirectMessagesViewController *)controller;

@end
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
#import "MBDirectMessageToolbar.h"

@protocol MBIndividualDirectMessagesViewControllerDelegate;
@class MBUserIDManager;
@class MBUser;
@class MBUnderLineToolbar;
@interface MBIndividualDirectMessagesViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate, MBMessageReceiverViewControllerDelegate, MBDirectMessageToolbarDelegate,  UITextViewDelegate, UIScrollViewDelegate>


@property (nonatomic, weak) id < MBIndividualDirectMessagesViewControllerDelegate > delegate;

@property (nonatomic, readonly) MBUserIDManager *userIDManager;
@property (nonatomic, readonly) MBUser *partner;
@property (nonatomic, readonly) NSMutableArray *conversation;
@property (nonatomic, readonly) NSMutableDictionary *nonSendMessages;

@property (weak, nonatomic) IBOutlet MBUnderLineToolbar *receiverToolbar;
@property (weak, nonatomic) IBOutlet UITextField *receiverTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, readonly, assign) BOOL isEditing;

- (void)setUserIDManager:(MBUserIDManager *)userIDManager;
- (void)setIsEditing:(BOOL)isEditing;
- (void)setPartner:(MBUser *)partner;
- (void)setConversation:(NSMutableArray *)conversation;

@end



@protocol MBIndividualDirectMessagesViewControllerDelegate <NSObject>

- (void)sendMessageIndividualDirectMessagesViewController:(MBIndividualDirectMessagesViewController *)controller;

@end
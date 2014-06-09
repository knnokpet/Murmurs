//
//  MBIndividualDirectMessagesViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAOuth_TwitterAPICenter.h"

@class MBUser;
@interface MBIndividualDirectMessagesViewController : UIViewController <MBAOuth_TwitterAPICenterDelegate, UITextViewDelegate>

@property (nonatomic, readonly) MBUser *partner;
@property (nonatomic, readonly) NSMutableArray *conversation;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIView *containedView;
@property (weak, nonatomic) IBOutlet UITextView *textView;


- (void)setPartner:(MBUser *)partner;
- (void)setConversation:(NSMutableArray *)conversation;

@end

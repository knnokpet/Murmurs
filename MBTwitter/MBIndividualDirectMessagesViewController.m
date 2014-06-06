//
//  MBIndividualDirectMessagesViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBIndividualDirectMessagesViewController.h"
#import "MBDirectMessage.h"
#import "MBUser.h"
#import "MBAccountManager.h"
#import "MBAccount.h"

@interface MBIndividualDirectMessagesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;

@end

@implementation MBIndividualDirectMessagesViewController
#pragma mark -
#pragma mark Initialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setPartner:(MBUser *)partner
{
    _partner = partner;
}

- (void)setConversation:(NSMutableArray *)conversation
{
    _conversation = conversation;
}

#pragma mark -
#pragma mark View
- (void)commonConfigureView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self commonConfigureNavigationItem];
}

- (void)commonConfigureNavigationItem
{
    UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(didPushReplyButton)];
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(didPushTrashButton)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:replyButton, trashButton, nil];
}

- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self commonConfigureModel];
    [self commonConfigureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action
- (void)didPushReplyButton
{
    [self.aoAPICenter postDirectMessage:@"test DIrectMessage" screenName:nil userID:77936670];
}

- (void)didPushTrashButton
{
    
}

#pragma mark -
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.conversation count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.conversation objectAtIndex:indexPath.row];
    cell.textLabel.text = message.tweetText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *deleteMessage = [self.conversation objectAtIndex:indexPath.row];
    NSLog(@"text = %@", deleteMessage.tweetText);
    NSLog(@"recipient = %@", deleteMessage.recipient.screenName);
    NSLog(@"sender = %@", deleteMessage.sender.screenName);
    NSLog(@"id = %llu", [[deleteMessage tweetID] unsignedLongLongValue]);
    
    [self.aoAPICenter postDestroyDirectMessagesRequireID:[[deleteMessage tweetID] unsignedLongLongValue]];
    
}

#pragma mark AOuth_APICenterDelegate

@end

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

@property (nonatomic) NSNumber *currentKeyboardHeight;

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
    
    self.textView.delegate = self;
    
    
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter addObserver:self selector:@selector(keyBoardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [nCenter addObserver:self selector:@selector(keyboardWillDIsappear:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.textView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Instance Methods
- (void)keyBoardWillAppear:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    
    contentInsets.bottom = keyboardSize.height + self.containedView.frame.size.height;
    scrollInsets.bottom = keyboardSize.height + self.containedView.frame.size.height;
    
    //CGRect containerFrame = self.containedView.frame;
    //containerFrame.origin.y = self.view.frame.size.height - keyboardSize.height - self.containedView.frame.size.height;
    
    self.currentKeyboardHeight = [NSNumber numberWithFloat:keyboardSize.height];
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        self.topConstraint.constant = self.view.frame.size.height - keyboardSize.height - self.toolbar.frame.size.height;
    }completion:^(BOOL stop) {
        
    }];
    
}

- (void)keyboardWillDIsappear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = 0;
    scrollInsets.bottom = 0;
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
    }completion:^(BOOL stop){
        
    }];
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

#pragma mark TextView Delegate
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    UITextView *sizingTextView = [[UITextView alloc] init];
    sizingTextView.attributedText = textView.attributedText;
    CGSize textSize = [sizingTextView sizeThatFits:CGSizeMake(self.containedView.frame.size.width, CGFLOAT_MAX)];
    NSLog(@"%@ contain = %f", textView.text, textSize.height);
    
    CGFloat defaultToolbarHeight = 44.0f;
    CGFloat defaultContainerViewHeight = 33.0f;
    CGFloat defaultToolbarItemMargin = 6.0f;
    NSInteger heightMargin = textSize.height - defaultToolbarHeight;
    if (0 < heightMargin) {
        
        CGFloat limitOriginY = (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
        CGFloat maxSpace = self.view.frame.size.height - self.currentKeyboardHeight.floatValue - (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
        
        CGFloat toolbarheight = defaultToolbarHeight + heightMargin;
        if (maxSpace < toolbarheight) {
            toolbarheight = maxSpace;
        }
        
        CGFloat toolbarOriginY = self.view.frame.size.height - self.currentKeyboardHeight.floatValue - toolbarheight;
        if (limitOriginY > toolbarOriginY) {
            toolbarOriginY = limitOriginY;
        }
        
        CGRect toolbarFrame = self.toolbar.frame;
        toolbarFrame.size.height = toolbarheight;
        toolbarFrame.origin.y = toolbarOriginY;
        self.toolbar.frame = toolbarFrame;
        
        
        CGFloat containerHeight = defaultContainerViewHeight + heightMargin;
        CGRect containerFrame = self.containedView.frame;
        containerFrame.size.height = containerHeight;
        self.containedView.frame = containerFrame;
        
        CGRect textFrame = self.textView.frame;
        if (containerHeight < textSize.height) {
            textSize.height = containerHeight;
        }
        textFrame.size.height = textSize.height;
        self.textView.frame = textFrame;
    }
    
}

@end

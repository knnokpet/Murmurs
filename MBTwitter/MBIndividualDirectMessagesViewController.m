//
//  MBIndividualDirectMessagesViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBIndividualDirectMessagesViewController.h"

#import "MBUserIDManager.h"
#import "MBDirectMessageManager.h"
#import "MBDirectMessage.h"
#import "MBTemporaryDirectMessage.h"
#import "MBUserManager.h"
#import "MBUser.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBTweetTextComposer.h"

#import "MBMessageTableViewCell.h"
#import "MBSendMessageTableViewCell.h"
#import "MBMessageView.h"
#import "MBTweetTextView.h"
#import "MBAvatorImageView.h"

static NSString *deliverdCellIdentifier = @"DeliverdCellIdentifier";
static NSString *sendCellIdentifier = @"SendCellIdentifier";

#define FONT_SIZE_MESSAGE 15.0f
#define LINE_SPACING_MESSAGE 4.0f
#define LINE_HEIGHT_MESSAGE 0.0f
#define PARAGRAPH_SPACING_MESSAGE 0.0f


@interface MBIndividualDirectMessagesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) MBMessageReceiverViewController *currentReceiverViewController;

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) NSMutableArray *dataSource;

@property (nonatomic) NSNumber *currentKeyboardHeight;
@property (nonatomic, assign) BOOL isShownKeyboard;
@property (nonatomic, assign) BOOL isDragging;

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
- (void)setUserIDManager:(MBUserIDManager *)userIDManager
{
    _userIDManager = userIDManager;
}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
}

- (void)setPartner:(MBUser *)partner
{
    _partner = partner;
}

- (void)setConversation:(NSMutableArray *)conversation
{
    _conversation = conversation;
}

- (NSMutableArray *)dataSource
{
    // decorate. conversion & nonSendMessage
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray:self.conversation];
    
    for (NSString *key in [self.nonSendMessages allKeys]) {
        MBTemporaryDirectMessage *temporaryMessage = [[MBTemporaryDirectMessage alloc] initWithText:key partner:self.partner];
        NSNumber *temporaryIndex = [self.nonSendMessages objectForKey:key];
        [dataSource insertObject:temporaryMessage atIndex:[temporaryIndex unsignedIntegerValue]];
    }
    
    return dataSource;
}

#pragma mark -
#pragma mark View
- (void)commonConfigureView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    UINib *deliverdCell = [UINib nibWithNibName:@"MBMessageTableViewCell" bundle:nil];
    [self.tableView registerNib:deliverdCell forCellReuseIdentifier:deliverdCellIdentifier];
    UINib *sendCell = [UINib nibWithNibName:@"MBSendMessageTableViewCell" bundle:nil];
    [self.tableView registerNib:sendCell forCellReuseIdentifier:sendCellIdentifier];
    
    
    self.textView.delegate = self;
    
    self.sendButton.title = NSLocalizedString(@"Send", nil);
    self.sendButton.enabled = NO;
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = self.toolbar.frame.size.height;
    scrollInsets.bottom = self.toolbar.frame.size.height;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = scrollInsets;
    
    [self commonConfigureNavigationItem];
}

- (void)configureMessageView
{
    CGFloat defaultTopConstant = 64.0f;
    CGFloat defaultBottomConstant = 49.0f;
    
    if (YES == self.isEditing) {
        
        UIEdgeInsets topInsets = self.tableView.contentInset;
        topInsets.top = defaultTopConstant ; //self.containedView.frame.size.height;
        self.tableView.contentInset = topInsets;
        
        [self.tableView setHidden:YES];
        
        [self.receiverTextField addTarget:self action:@selector(didChangeTextField) forControlEvents:UIControlEventEditingChanged];
        
        
    } else {
        
        UIEdgeInsets topInsets = self.tableView.contentInset;
        topInsets.top = defaultTopConstant;
        //self.tableView.contentInset = topInsets;
        
        [self.tableView setHidden:NO];
        [self.view insertSubview:self.toolbar aboveSubview:self.tableView];
        
        [self.receiverToolbar removeFromSuperview];
    }
}

- (void)commonConfigureNavigationItem
{
    self.containedView.layer.cornerRadius = 4.0f;
}

- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    _nonSendMessages = [NSMutableDictionary dictionary];
    self.dataSource = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self commonConfigureModel];
    [self commonConfigureView];
    
    [self configureMessageView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter addObserver:self selector:@selector(keyBoardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [nCenter addObserver:self selector:@selector(keyboardWillDIsappear:) name:UIKeyboardWillHideNotification object:nil];
    NSLog(@"container = %f", self.containedView.frame.size.height);
    NSLog(@"textview height = %f", self.textView.frame.size.height);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.receiverToolbar.superview) {
        [self.receiverTextField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.tableView.delegate = nil;
    self.textView.delegate = nil;
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
    self.currentKeyboardHeight = [NSNumber numberWithFloat:keyboardSize.height];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = keyboardSize.height + self.toolbar.frame.size.height;
    scrollInsets.bottom = keyboardSize.height + self.toolbar.frame.size.height;
    
    
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.y = self.view.frame.size.height - self.currentKeyboardHeight.floatValue - self.toolbar.frame.size.height;
    
    duration += 0.5;
    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        
        self.currentReceiverViewController.tableView.contentInset = contentInsets;
        self.currentReceiverViewController.tableView.scrollIndicatorInsets = scrollInsets;
        
        self.toolbar.frame = toolbarFrame;
    }completion:^(BOOL stop) {
        self.isShownKeyboard = YES;
    }];
    
}

- (void)keyboardWillDIsappear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = self.tabBarController.tabBar.frame.size.height + self.toolbar.frame.size.height;
    scrollInsets.bottom = self.tabBarController.tabBar.frame.size.height + self.toolbar.frame.size.height;
    
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.y = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - self.toolbar.frame.size.height;
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        
        self.currentReceiverViewController.tableView.contentInset = contentInsets;
        self.currentReceiverViewController.tableView.scrollIndicatorInsets = scrollInsets;
        
        self.toolbar.frame = toolbarFrame;
    }completion:^(BOOL stop){
        self.isShownKeyboard = NO;
    }];
}

- (NSArray *)suggestedUserIDs:(NSArray *)resourceArray suggestString:(NSString *)suggestString
{
    NSString *lowerSeggestString = [suggestString lowercaseString];
    NSMutableArray *results = [NSMutableArray array];
    MBUserManager *userManager = [MBUserManager sharedInstance];
    for (NSString *userIDStr in resourceArray) {
        MBUser *user = [userManager storedUserForKey:userIDStr];
        NSString *characterString = [user.characterName lowercaseString];
        if (NSNotFound != [characterString rangeOfString:lowerSeggestString].location) {
            [results addObject:userIDStr];
            continue;
        }
        
        NSString *screenNameString = [user.screenName lowercaseString];
        if (NSNotFound != [screenNameString rangeOfString:lowerSeggestString].location) {
            [results addObject:userIDStr];
            continue;
        }
    }
    
    return results;
}

#pragma mark Action

- (IBAction)didPushSendButton:(id)sender {
    
    if (!self.partner) {
        return;
    }
    
    NSString *sendMessage = self.textView.text;
    [self.nonSendMessages setObject:[NSNumber numberWithInt:[self.dataSource count]] forKey:sendMessage];
    if (self.isEditing) {
        self.isEditing = NO;
        [self configureMessageView];
        
    }
    
    [self.tableView reloadData];
    
    [self.aoAPICenter postDirectMessage:sendMessage screenName:self.partner.screenName userID:[self.partner.userID unsignedLongLongValue]];
    
}

- (IBAction)didPushCameraButton:(id)sender {
}

- (void)didChangeTextField
{
    NSLog(@"didchange %@", self.receiverTextField.text);
    
    NSUInteger textLength = self.receiverTextField.text.length;
    NSString *suggestString = self.receiverTextField.text;
    
    if (self.currentReceiverViewController.view.superview) {
        [self.currentReceiverViewController removeFromParentViewController];
        [self.currentReceiverViewController.view removeFromSuperview];
    }
    if (self.tableView.superview) {
        [self.tableView setHidden:YES];
    }
    
    if (0 < textLength) {
        self.currentReceiverViewController = [[MBMessageReceiverViewController alloc] init];
        NSArray *userIDs = [self.userIDManager storedUserIDs];
        self.currentReceiverViewController.dataSource = [self suggestedUserIDs:userIDs suggestString:suggestString];
        self.currentReceiverViewController.inputedString = suggestString;
        self.currentReceiverViewController.delegate = self;
        [self.currentReceiverViewController.tableView reloadData];
        
        
        [self addChildViewController:self.currentReceiverViewController];
        [self.view insertSubview:self.currentReceiverViewController.view belowSubview:self.receiverToolbar];
        
        UIEdgeInsets tableViewInset = self.tableView.contentInset;
        tableViewInset.top = 64.0f + self.containedView.frame.size.height;
        tableViewInset.bottom = self.tabBarController.tabBar.frame.size.height;
        self.currentReceiverViewController.tableView.contentInset = tableViewInset;
        self.currentReceiverViewController.tableView.scrollIndicatorInsets = tableViewInset;
        
    } else if (0 == textLength) {
        [self.tableView setHidden:YES];
        [self.view insertSubview:self.receiverToolbar aboveSubview:self.tableView];
    }
    
    [self.view insertSubview:self.toolbar aboveSubview:self.receiverToolbar];
}

#pragma mark -
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.dataSource objectAtIndex:indexPath.row];
    NSAttributedString *attributedString = [MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]];
    
    CGFloat messageViewMargin = 4.0 + 4.0;
    CGFloat textViewMargin = 4.0 + 4.0;
    
    
    // calculate textView
    NSInteger textViewWidthSpace = tableView.bounds.size.width - (42 + 54) - textViewMargin;
    CGFloat lineSpace = LINE_SPACING_MESSAGE;
    CGFloat fontSize = FONT_SIZE_MESSAGE;
    CGRect textViewRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(textViewWidthSpace, CGFLOAT_MAX) lineSpace:lineSpace font:[UIFont systemFontOfSize:fontSize]];
    
    CGFloat cellHeight = textViewRect.size.height + messageViewMargin + textViewMargin;
    CGFloat defaultHeight = 40;
    
    return MAX(defaultHeight, cellHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.dataSource objectAtIndex:indexPath.row];
    BOOL isPartner = ([message.sender.userIDStr isEqualToString:self.partner.userIDStr])? YES : NO;
    
    UITableViewCell *cell;
    if (YES == isPartner) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:deliverdCellIdentifier];
        [self updateDeliverdCell:(MBMessageTableViewCell *)cell atIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:sendCellIdentifier];
        [self updateSentCell:(MBSendMessageTableViewCell *)cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)updateDeliverdCell:(MBMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE_MESSAGE];
    cell.tweetTextView.lineSpace = LINE_SPACING_MESSAGE;
    cell.tweetTextView.lineHeight = LINE_HEIGHT_MESSAGE;
    cell.tweetTextView.paragraphSpace = PARAGRAPH_SPACING_MESSAGE;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]];
    CGRect longestRect = [MBTweetTextView rectForLongestDrawingTextWithAttributedString:[MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]] constraintSize:cell.tweetTextView.frame.size lineSpace:LINE_SPACING_MESSAGE paragraghSpace:PARAGRAPH_SPACING_MESSAGE font:[UIFont systemFontOfSize:FONT_SIZE_MESSAGE]];
    [cell setTweetViewRect:longestRect];
}

- (void)updateSentCell:(MBSendMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE_MESSAGE];
    cell.tweetTextView.lineSpace = LINE_SPACING_MESSAGE;
    cell.tweetTextView.lineHeight = LINE_HEIGHT_MESSAGE;
    cell.tweetTextView.paragraphSpace = PARAGRAPH_SPACING_MESSAGE;
    cell.tweetTextView.textColor = [UIColor whiteColor];
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]];
    CGRect longestRect = [MBTweetTextView rectForLongestDrawingTextWithAttributedString:[MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]] constraintSize:cell.tweetTextView.frame.size lineSpace:LINE_SPACING_MESSAGE paragraghSpace:PARAGRAPH_SPACING_MESSAGE font:[UIFont systemFontOfSize:FONT_SIZE_MESSAGE]];
    [cell setTweetViewRect:longestRect];
    
    [cell.messageView setPopsFromRight:YES];
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[MBTemporaryDirectMessage class]]) {
        MBTemporaryDirectMessage *temporaryMessage = obj;
        cell.textLabel.text = temporaryMessage.text;
        cell.detailTextLabel.text = NSLocalizedString(@"Sending...", nil);
        cell.backgroundColor = [UIColor blueColor];
        
    } else if ([obj isKindOfClass:[MBDirectMessage class]]) {
        MBDirectMessage *message = obj;
        cell.textLabel.text = message.tweetText;
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *deleteMessage = [self.dataSource objectAtIndex:indexPath.row];
    
    [self.aoAPICenter postDestroyDirectMessagesRequireID:[[deleteMessage tweetID] unsignedLongLongValue]];
    
}

#pragma mark TextView Delegate
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
    UITextView *sizingTextView = [[UITextView alloc] init];
    sizingTextView.attributedText = textView.attributedText;
    CGSize textSize = [sizingTextView sizeThatFits:CGSizeMake(self.containedView.frame.size.width, CGFLOAT_MAX)];
    NSLog(@"%@ contain = %f", textView.text, textSize.height);
    
    CGFloat defaultToolbarHeight = 44.0f;
    CGFloat defaultContainerViewHeight = 33.0f;
    CGFloat defaultTextVIewHeight = 36.5;
    NSInteger heightMargin = textSize.height - defaultToolbarHeight;
    
    CGFloat toolbarheight = defaultToolbarHeight;
    CGFloat toolbarOriginY = self.view.frame.size.height - self.currentKeyboardHeight.floatValue - toolbarheight;
    CGFloat textViewHeight = defaultTextVIewHeight;
    
    
    CGFloat limitOriginY = (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
    CGFloat maxSpace = self.view.frame.size.height - self.currentKeyboardHeight.floatValue - (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
    
    
    if (0 < heightMargin) {
        toolbarheight = defaultToolbarHeight + heightMargin;
        if (maxSpace < toolbarheight) {
            toolbarheight = maxSpace;
        }
        
        toolbarOriginY = self.view.frame.size.height - self.currentKeyboardHeight.floatValue - toolbarheight;
        if (limitOriginY > toolbarOriginY) {
            toolbarOriginY = limitOriginY;
        }
        
        textViewHeight = textSize.height;
    }
    
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.size.height = toolbarheight;
    toolbarFrame.origin.y = toolbarOriginY;
    self.toolbar.frame = toolbarFrame;
    
    
    CGFloat containerHeight = defaultContainerViewHeight + heightMargin;
    if (toolbarheight < containerHeight) {
        containerHeight = toolbarheight;
    }
    CGRect containerFrame = self.containedView.frame;
    containerFrame.size.height = containerHeight;
    self.containedView.frame = containerFrame;
    
    CGRect textFrame = self.textView.frame;
    self.textView.scrollEnabled = NO;
    if (containerHeight < textViewHeight) {
        textViewHeight = containerHeight - (6.0f + 6.0f);
        self.textView.scrollEnabled = YES;
    }
    textFrame.size.height = textViewHeight;
    self.textView.frame = textFrame;
    NSLog(@"container = %f text = %f", self.containedView.frame.size.height, self.textView.frame.size.height);
    
    
    // enable sendButton
    if (0 < self.textView.text.length  && self.partner) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (NO == self.isShownKeyboard) {
        return;
    }
    if (scrollView != self.tableView) {
        return;
    }
    
    
    CGPoint touchPoint = [scrollView.panGestureRecognizer locationInView:self.view];
    NSLog(@"point x = %f y %f", touchPoint.x, touchPoint.y);
    if (YES == self.isDragging) {
        
        CGFloat defaultToolbarOriginY = self.view.frame.size.height - self.currentKeyboardHeight.floatValue - self.toolbar.frame.size.height;
        CGFloat bottomToolbarOriginY = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - self.toolbar.frame.size.height;
        
        CGRect toolbarFrame = self.toolbar.frame;
        if (defaultToolbarOriginY < touchPoint.y) {
            toolbarFrame.origin.y = touchPoint.y;
            
            if (bottomToolbarOriginY < touchPoint.y) {
                toolbarFrame.origin.y = bottomToolbarOriginY;
            }
            
        } else if (defaultToolbarOriginY > touchPoint.y) {
            toolbarFrame.origin.y = defaultToolbarOriginY;
        }
        
        self.toolbar.frame = toolbarFrame;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView != self.tableView) {
        return;
    }
    
    self.isDragging = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView != self.tableView) {
        return;
    }
    
    self.isDragging = NO;
    
    CGPoint touchPoint = [scrollView.panGestureRecognizer locationInView:self.view];
    CGFloat currentKeyBoardOriginY = self.view.frame.size.height - self.currentKeyboardHeight.floatValue;
    if (currentKeyBoardOriginY < touchPoint.y) {
        CGFloat bottomToolbarOriginY = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - self.toolbar.frame.size.height;
        CGRect frame = self.toolbar.frame;
        frame.origin.y = bottomToolbarOriginY;
        //self.toolbar.frame = frame;
    }
}


#pragma mark MessageReceiverViewController Delegate
- (void)selectReceiverViewController:(MBMessageReceiverViewController *)controller user:(MBUser *)user
{
    if (controller.view.superview) {
        [controller.view removeFromSuperview];
    }
    
    self.receiverTextField.text = user.screenName;
    
    if (user) {
        [self setPartner:user];
    }
    
    NSMutableArray *messages = [[MBDirectMessageManager sharedInstance] separatedMessagesForKey:user.userIDStr];
    if (messages) {
        
        [self setConversation:messages];
        [self.tableView reloadData];
        [self.tableView setHidden:NO];
        [self.view insertSubview:self.tableView belowSubview:self.receiverToolbar];
        [self.view insertSubview:self.toolbar aboveSubview:self.tableView];
    }
    
    //[self.textView becomeFirstResponder];
}

- (void)selectSearchReceiverViewController:(MBMessageReceiverViewController *)controller
{
    
}

- (void)scrollReceiverViewController:(MBMessageReceiverViewController *)controller
{
    if ([self.receiverTextField isFirstResponder]) {
        [self.receiverTextField resignFirstResponder];
    }
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedDirectMessages:(NSArray *)messages
{
    if (0 < messages.count) {
        MBDirectMessage *gotMessage = [messages firstObject];
        if (gotMessage) {
            
            [self.nonSendMessages removeObjectForKey:gotMessage.tweetText];
            NSMutableArray *messages = [[MBDirectMessageManager sharedInstance] separatedMessagesForKey:self.partner.userIDStr];
            [self setConversation:messages];
            [self.tableView reloadData];
            
            if ([_delegate respondsToSelector:@selector(sendMessageIndividualDirectMessagesViewController:)]) {
                [_delegate sendMessageIndividualDirectMessagesViewController:self];
            }
        }
    }
}

@end

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
#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"

#import "MBMessageTableViewCell.h"
#import "MBSendMessageTableViewCell.h"
#import "MBMessageView.h"
#import "MBTweetTextView.h"
#import "MBAvatorImageView.h"
#import "MBUnderLineToolbar.h"

static NSString *deliverdCellIdentifier = @"DeliverdCellIdentifier";
static NSString *sendCellIdentifier = @"SendCellIdentifier";

#define FONT_SIZE_MESSAGE 15.0f
#define LINE_SPACING_MESSAGE 4.0f
#define LINE_HEIGHT_MESSAGE 0.0f
#define PARAGRAPH_SPACING_MESSAGE 0.0f


@interface MBIndividualDirectMessagesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    CGPoint defaultToolBarPoint;
    CGSize defaultToolBarSize;
    CGSize defaultTextViewSize;
}

@property (nonatomic) MBMessageReceiverViewController *currentReceiverViewController;

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic, readonly) NSMutableDictionary *cachedCellRects;

@property (nonatomic) UIImage *partnerImage;
@property (nonatomic) UIImage *myAccountImage;

@property (nonatomic, readonly) UIToolbar *toolBar;
@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, readonly) UIBarButtonItem *cameraButton;
@property (nonatomic, readonly) UIBarButtonItem *sendButton;

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
    
    
    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(didPushCameraButton:)]; /* unused */
    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didPushSendButton:)];
    
    defaultTextViewSize = CGSizeMake(210, 32);
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, defaultTextViewSize.width, defaultTextViewSize.height)];
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.font = [UIFont systemFontOfSize:17.0f];
    UIBarButtonItem *textBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.textView];
    

    defaultToolBarSize = CGSizeMake(self.view.bounds.size.width, 44.0f);
    defaultToolBarPoint = CGPointMake(0,self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - defaultToolBarSize.height);
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, defaultToolBarPoint.y, defaultToolBarSize.width, defaultToolBarSize.height)];
    [self.toolBar setItems:@[self.cameraButton, textBarItem, self.sendButton]];
    self.textView.delegate = self;
    __weak UIView *toolBar = self.toolBar;
    self.textView.inputAccessoryView = toolBar;
    [self.view addSubview:self.toolBar];
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = self.toolBar.frame.size.height;
    scrollInsets.bottom = self.toolBar.frame.size.height;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = scrollInsets;

    self.sendButton.title = NSLocalizedString(@"Send", nil);
    self.sendButton.enabled = NO;
    
    [self commonConfigureNavigationItem];
}

- (void)configureMessageView
{
    if (YES == self.isEditing) {
        
        UIEdgeInsets topInsets = self.tableView.contentInset;
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
        topInsets.top = self.receiverToolbar.bounds.size.height;
        scrollInsets.top = self.receiverToolbar.bounds.size.height;
        self.tableView.contentInset = topInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        
        [self.tableView setHidden:YES];
        
        [self.receiverTextField addTarget:self action:@selector(didChangeTextField) forControlEvents:UIControlEventEditingChanged];
        __weak UIView *toolBar = self.toolBar;
        self.receiverTextField.inputAccessoryView = toolBar;
        
    } else {
        
        [self.tableView setHidden:NO];
        
        [self.receiverToolbar removeFromSuperview];
    }
}

- (void)commonConfigureNavigationItem
{
    
}

- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    _nonSendMessages = [NSMutableDictionary dictionary];
    self.dataSource = [NSMutableArray array];
    _cachedCellRects = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self commonConfigureModel];
    [self commonConfigureView];
    
    
    [self configureMessageView];
    
    if (self.dataSource.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    
    [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter addObserver:self selector:@selector(keyBoardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [nCenter addObserver:self selector:@selector(keyboardWillDIsappear:) name:UIKeyboardWillHideNotification object:nil];
    [nCenter addObserver:self selector:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
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
    
    [self.textView resignFirstResponder];
    
    self.tableView.delegate = nil;
    self.textView.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
    [nCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [nCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
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
    contentInsets.bottom = keyboardSize.height;
    scrollInsets.bottom = keyboardSize.height;
    
    
    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        
        self.currentReceiverViewController.tableView.contentInset = contentInsets;
        self.currentReceiverViewController.tableView.scrollIndicatorInsets = scrollInsets;
        
        if (self.dataSource.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
        
    }completion:^(BOOL stop) {
        
    }];
    
}

- (void)keyboardWillDIsappear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    CGRect toolBarRect = CGRectMake(0, self.view.frame.size.height, defaultToolBarSize.width, self.toolBar.frame.size.height);
    self.toolBar.frame = toolBarRect;
    [self.view addSubview:self.toolBar];
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = self.tabBarController.tabBar.frame.size.height + self.toolBar.frame.size.height;
    scrollInsets.bottom = self.tabBarController.tabBar.frame.size.height + self.toolBar.frame.size.height;
    
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        
        self.currentReceiverViewController.tableView.contentInset = contentInsets;
        self.currentReceiverViewController.tableView.scrollIndicatorInsets = scrollInsets;
        
    }completion:^(BOOL stop){
        
    }];
}

- (void)keyboardDidDisappear:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];

    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        CGFloat toolBarOriginY = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - self.toolBar.frame.size.height;
        CGRect toolBarRect = CGRectMake(0, toolBarOriginY, defaultToolBarSize.width, self.toolBar.frame.size.height);
        self.toolBar.frame = toolBarRect;
        [self.view addSubview:self.toolBar];
    }completion:nil];
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

- (CGRect)cellRectForMessage:(MBDirectMessage *)message constraintSize:(CGSize)size
{
    CGRect cellRect = CGRectZero;
    NSString *keyX = @"x";
    NSString *keyY = @"y";
    NSString *keyWidth = @"width";
    NSString *keyHeight = @"height";
    
    NSDictionary *cachedRectDict = [self.cachedCellRects objectForKey:message.tweetID];
    if (cachedRectDict) {
        CGFloat x, y, width, height;
        
        x = [(NSNumber *)[cachedRectDict objectForKey:keyX] floatValue];
        y = [(NSNumber *)[cachedRectDict objectForKey:keyY] floatValue];
        width = [(NSNumber *)[cachedRectDict objectForKey:keyWidth] floatValue];
        height = [(NSNumber *)[cachedRectDict objectForKey:keyHeight] floatValue];
        cellRect = CGRectMake(x, y, width, height);
        return cellRect;
    }
    
    CGRect longestRect = [MBTweetTextView rectForLongestDrawingTextWithAttributedString:[MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]] constraintSize:size lineSpace:LINE_SPACING_MESSAGE paragraghSpace:PARAGRAPH_SPACING_MESSAGE font:[UIFont systemFontOfSize:FONT_SIZE_MESSAGE]];
    NSNumber *x, *y, *width, *height;
    x = [NSNumber numberWithFloat:longestRect.origin.x];
    y = [NSNumber numberWithFloat:longestRect.origin.y];
    width = [NSNumber numberWithFloat:longestRect.size.width];
    height = [NSNumber numberWithFloat:longestRect.size.height];
    NSDictionary *cachedDict = @{keyX: x, keyY : y, keyWidth: width, keyHeight: height};
    [self.cachedCellRects setObject:cachedDict forKey:message.tweetID];
    
    return longestRect;
}

- (NSString *)dateStringWithMessage:(MBDirectMessage *)message
{
    NSCalendar *calendaar = [NSCalendar currentCalendar];
    NSTimeZone *currentTimezone = calendaar.timeZone;
    NSDateComponents *components = [calendaar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:message.createdDate];
    
    NSInteger second = [currentTimezone secondsFromGMT];
    int hour = second / (60 * 60);
    if (hour < 1) {
        int minute = second / 60;
        [components setMinute:components.minute - minute];
    } else {
        [components setHour:components.hour - hour];
        if (components.hour < 0) {
            [components setDay:components.day - 1];
            [components setHour:24 + components.hour];
        }
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%d/%02d/%02d %02d:%02d", components.year, components.month, components.day, components.hour, components.minute];
    
    return dateString;
}

#pragma mark Action

- (IBAction)didPushSendButton:(id)sender {
    
    if (!self.partner) {
        return;
    }
    
    NSString *sendMessage = self.textView.text;
    
    NSUInteger nonSentIndexRow = [self.dataSource count];
    NSNumber *nonSendIndex = [NSNumber numberWithUnsignedInteger:nonSentIndexRow];
    [self.nonSendMessages setObject:nonSendIndex forKey:sendMessage];
    if (self.isEditing) {
        self.isEditing = NO;
        [self configureMessageView];
        
    }
    
    
    NSIndexPath *sendingIndexPath = [NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[sendingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.aoAPICenter postDirectMessage:sendMessage screenName:self.partner.screenName userID:[self.partner.userID unsignedLongLongValue]];
    
    self.textView.text = @"";
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
        self.currentReceiverViewController.view.frame = self.view.bounds;
        UIEdgeInsets tableViewInset = self.tableView.contentInset;
        UIEdgeInsets scrollInset = self.tableView.scrollIndicatorInsets;
        tableViewInset.bottom = self.tabBarController.tabBar.frame.size.height;
        scrollInset.bottom = self.tabBarController.tabBar.frame.size.height;
        self.currentReceiverViewController.tableView.contentInset = tableViewInset;
        self.currentReceiverViewController.tableView.scrollIndicatorInsets = scrollInset;
        
        NSArray *userIDs = [self.userIDManager storedUserIDs];
        self.currentReceiverViewController.dataSource = [self suggestedUserIDs:userIDs suggestString:suggestString];
        self.currentReceiverViewController.inputedString = suggestString;
        self.currentReceiverViewController.delegate = self;
        [self.currentReceiverViewController.tableView reloadData];
        [self addChildViewController:self.currentReceiverViewController];

        [self.view insertSubview:self.currentReceiverViewController.view belowSubview:self.receiverToolbar];
        
        
    } else if (0 == textLength) {
        [self.tableView setHidden:YES];
        [self.view insertSubview:self.receiverToolbar aboveSubview:self.tableView];
    }
    
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
    
    CGFloat messageViewVerticalMargin = 8.0;
    CGFloat dateLabelHeight = 14.0f;
    CGFloat dateLabelVerticalMargin = 2.0f + 8.0f;
    CGFloat textViewSideMargin = 12.0 + 16.0;
    CGFloat textViewUpMargin = 12.0f + 12.0f;
    
    
    // calculate textView
    NSInteger textViewWidthSpace = tableView.bounds.size.width - (50 + 60) - textViewSideMargin;
    CGFloat lineSpace = LINE_SPACING_MESSAGE;
    CGFloat fontSize = FONT_SIZE_MESSAGE;
    CGRect textViewRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(textViewWidthSpace, CGFLOAT_MAX) lineSpace:lineSpace font:[UIFont systemFontOfSize:fontSize]];
    
    CGFloat cellHeight = textViewRect.size.height + messageViewVerticalMargin + textViewUpMargin + dateLabelHeight + dateLabelVerticalMargin;
    
    return cellHeight;
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
    
    cell.dateString = [self dateStringWithMessage:message];
    
    // MessageText
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE_MESSAGE];
    cell.tweetTextView.lineSpace = LINE_SPACING_MESSAGE;
    cell.tweetTextView.lineHeight = LINE_HEIGHT_MESSAGE;
    cell.tweetTextView.paragraphSpace = PARAGRAPH_SPACING_MESSAGE;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]];
    CGRect longestRect = [self cellRectForMessage:message constraintSize:CGSizeMake(self.view.bounds.size.width - (cell.messageView.frame.origin.x + cell.messageViewRightSpaceConstraint.constant), CGFLOAT_MAX)];

    [cell setTweetViewRect:longestRect];
    
    UIImage *partnerImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:message.sender.userIDStr];
    if (partnerImage) {
        CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:partnerImage size:avatorSize radius:4];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatorImageView.image = radiusImage;
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadOriginImageWithURL:message.sender.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:message.sender.userIDStr];
                CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
                UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:avatorSize radius:4];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatorImageView.image = radiusImage;
                });
            }failedHandler:^(NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}

- (void)updateSentCell:(MBSendMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.dateString = [self dateStringWithMessage:message];
    
    // messageText
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE_MESSAGE];
    cell.tweetTextView.lineSpace = LINE_SPACING_MESSAGE;
    cell.tweetTextView.lineHeight = LINE_HEIGHT_MESSAGE;
    cell.tweetTextView.paragraphSpace = PARAGRAPH_SPACING_MESSAGE;
    cell.tweetTextView.textColor = [UIColor whiteColor];
    if ([message isKindOfClass:[MBTemporaryDirectMessage class]]) {
        cell.tweetTextView.textColor = [UIColor redColor];
    }
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]];
    CGRect longestRect = [self cellRectForMessage:message constraintSize:CGSizeMake(self.view.bounds.size.width - (cell.messageView.frame.origin.x + cell.messageViewLeftSpaceConstraint.constant), CGFLOAT_MAX)];
    [cell setTweetViewRect:longestRect];
    [cell.messageView setPopsFromRight:YES];
    
    UIImage *partnerImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:message.sender.userIDStr];
    if (partnerImage) {
        CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:partnerImage size:avatorSize radius:4];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatorImageView.image = radiusImage;
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadOriginImageWithURL:message.sender.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:message.sender.userIDStr];
                CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
                UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:avatorSize radius:4];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatorImageView.image = radiusImage;
                });
            }failedHandler:^(NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *deleteMessage = [self.dataSource objectAtIndex:indexPath.row];
    
    [self.aoAPICenter postDestroyDirectMessagesRequireID:[[deleteMessage tweetID] unsignedLongLongValue]];
    
}

#pragma mark TextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder]; // keyboard 表示トリガー
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
    UITextView *sizingTextView = [[UITextView alloc] init];
    sizingTextView.attributedText = textView.attributedText;
    CGSize textSize = [sizingTextView sizeThatFits:CGSizeMake(defaultTextViewSize.width, CGFLOAT_MAX)];
    
    CGFloat defaultTabbarItemMargin = 6.0f;
    CGFloat defaultToolbarHeight = defaultToolBarSize.height;
    CGFloat textViewHeightMargin = textSize.height - defaultTextViewSize.height;
    CGFloat defaultKeyBoardHeight = self.currentKeyboardHeight.floatValue - textView.inputAccessoryView.frame.size.height;
    
    
    CGFloat limitOriginY = (self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
    CGFloat maxSpace = self.view.bounds.size.height - limitOriginY - defaultKeyBoardHeight;
    
    CGFloat toolbarHeight = defaultToolbarHeight + textViewHeightMargin;
    CGFloat textViewHeight;
    
    if (toolbarHeight > maxSpace) {
        toolbarHeight = maxSpace;
    }
    
    textViewHeight = toolbarHeight -(defaultTabbarItemMargin * 2) ;
    
    CGRect toolBarRect = self.toolBar.frame;
    toolBarRect.size.height = toolbarHeight;
    self.toolBar.frame = toolBarRect;
    
    CGRect textFrame = self.textView.frame;
    textFrame.size.height = textViewHeight;
    self.textView.frame = textFrame;
    
    
    // enable sendButton
    if (0 < self.textView.text.length  && self.partner) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
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
        [self.view insertSubview:self.toolBar aboveSubview:self.tableView];
    }
}

- (void)selectSearchReceiverViewController:(MBMessageReceiverViewController *)controller
{
    if (self.receiverTextField.text > 0) {
        NSString *query = self.receiverTextField.text;
        [self.aoAPICenter getSearchedUsersWithQuery:query page:0];
    }
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

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users
{
    if (users.count > 0) {
        NSMutableArray *userIDs = [NSMutableArray array];
        for (MBUser *user in users) {
            [userIDs addObject:user.userIDStr];
        }
        self.currentReceiverViewController.dataSource = userIDs;
        self.currentReceiverViewController.inputedString = @"";
        [self.currentReceiverViewController.tableView reloadData];
    }
}

@end

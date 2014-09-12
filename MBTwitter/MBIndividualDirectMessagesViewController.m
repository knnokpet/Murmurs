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


#import "MBMessageView.h"
#import "MBTweetTextView.h"
#import "MBAvatorImageView.h"
#import "MBUnderLineToolbar.h"
#import "MBIndividualMessageTableViewCell.h"

static NSString *deliverdCellIdentifier = @"DeliverdCellIdentifier";
static NSString *sendCellIdentifier = @"SendCellIdentifier";

#define FONT_SIZE_MESSAGE 17.0f
#define LINE_SPACING_MESSAGE 4.0f
#define LINE_HEIGHT_MESSAGE 0.0f
#define PARAGRAPH_SPACING_MESSAGE 0.0f


@interface MBIndividualDirectMessagesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    CGPoint defaultToolBarPoint;
    CGSize defaultToolBarSize;
}

@property (nonatomic) MBMessageReceiverViewController *currentReceiverViewController;

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic, readonly) NSMutableDictionary *cachedCellRects;

@property (nonatomic) UIImage *partnerImage;
@property (nonatomic) UIImage *myAccountImage;

@property (nonatomic, readonly) MBDirectMessageToolbar *displayToolbar;
@property (nonatomic, readonly) MBDirectMessageToolbar *keyboardToolbar;


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
    
    NSString *title = [NSString stringWithFormat:@"%@", self.partner.screenName];
    self.title = title;
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

    

    defaultToolBarSize = CGSizeMake(self.view.bounds.size.width, 44.0f);
    defaultToolBarPoint = CGPointMake(0,self.tabBarController.tabBar.frame.origin.y - defaultToolBarSize.height);

    
    [self configureInputAccessoryToolbar];

    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = self.displayToolbar.frame.size.height;
    scrollInsets.bottom = self.displayToolbar.frame.size.height;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = scrollInsets;

    
    [self commonConfigureNavigationItem];
}

- (void)configureMessageView
{
    if (YES == self.isEditing) {
        self.title = NSLocalizedString(@"New Message", nil);
        
        UIEdgeInsets topInsets = self.tableView.contentInset;
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
        topInsets.top = self.receiverToolbar.bounds.size.height;
        scrollInsets.top = self.receiverToolbar.bounds.size.height;
        self.tableView.contentInset = topInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        
        [self.tableView setHidden:YES];
        
        [self.receiverTextField addTarget:self action:@selector(didChangeTextField) forControlEvents:UIControlEventEditingChanged];
        self.receiverTextField.inputAccessoryView = self.keyboardToolbar;
        
    } else {
        
        [self.tableView setHidden:NO];
        
        [self.receiverToolbar removeFromSuperview];
    }
}

- (void)configureInputAccessoryToolbar
{
    _displayToolbar = [[MBDirectMessageToolbar alloc] initWithFrame:CGRectMake(0, defaultToolBarPoint.y, defaultToolBarSize.width, defaultToolBarSize.height) maxSpace:self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height) - (defaultToolBarSize.height) - (self.tabBarController.tabBar.bounds.size.height)];
    [self.displayToolbar.sendButton setTarget:self];
    [self.displayToolbar.sendButton setAction:@selector(didPushSendButton:)];
    self.displayToolbar.textView.delegate = self;
    [self.view addSubview:self.displayToolbar];
    
    _keyboardToolbar = [[MBDirectMessageToolbar alloc] initWithFrame:CGRectMake(0, 0, defaultToolBarSize.width, defaultToolBarSize.height)];
    self.keyboardToolbar.toolbarDelegate = self;
    [self.keyboardToolbar.sendButton setTarget:self];
    [self.keyboardToolbar.sendButton setAction:@selector(didPushSendButton:)];
    
    self.displayToolbar.textView.inputAccessoryView = self.keyboardToolbar;
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
    NSString *title = [NSString stringWithFormat:@"%@", self.partner.screenName];
    self.title = title;
    
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
    
    [self.displayToolbar.textView resignFirstResponder];
    [self.keyboardToolbar.textView resignFirstResponder];
    self.keyboardToolbar.textView.delegate = nil;
    
    self.tableView.delegate = nil;
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
    self.keyboardToolbar.maxSpace = self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height) - (keyboardSize.height - self.keyboardToolbar.bounds.size.height);
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
    [self.keyboardToolbar.textView resignFirstResponder];
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    contentInsets.bottom = self.tabBarController.tabBar.frame.size.height + self.displayToolbar.frame.size.height;
    scrollInsets.bottom = self.tabBarController.tabBar.frame.size.height + self.displayToolbar.frame.size.height;
    
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
        
        self.currentReceiverViewController.tableView.contentInset = contentInsets;
        self.currentReceiverViewController.tableView.scrollIndicatorInsets = scrollInsets;
        
    }completion:^(BOOL stop){
        
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
    
    NSString *sendMessage = self.keyboardToolbar.textView.text;
    
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
    
    self.keyboardToolbar.textView.text = @"";
    self.displayToolbar.textView.text = @"";
}

- (IBAction)didPushCameraButton:(id)sender {
}

- (void)didChangeTextField
{
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
    CGFloat dateLabelHeight = 12.0f;
    CGFloat dateLabelVerticalMargin = 2.0f + 8.0f;
    CGFloat textViewUpMargin = 12.0f + 12.0f;
    
    
    // calculate textView
    MBIndividualMessageTableViewCell *sizingCell = [[MBIndividualMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Sizing"];
    CGFloat lineSpace = LINE_SPACING_MESSAGE;
    CGFloat fontSize = FONT_SIZE_MESSAGE;
    CGRect textViewRect = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:CGSizeMake(sizingCell.maxTweetTextViewWidth, CGFLOAT_MAX) lineSpace:lineSpace font:[UIFont systemFontOfSize:fontSize]];
    
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
        if (!cell) {
            cell = [[MBIndividualMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deliverdCellIdentifier];
        }
        [self updateDeliverdCell:(MBIndividualMessageTableViewCell *)cell atIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:sendCellIdentifier];
        if (!cell) {
            cell = [[MBIndividualMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sendCellIdentifier];
        }
        [self updateSentCell:(MBIndividualMessageTableViewCell *)cell atIndexPath:indexPath];
    }
    
    cell.userInteractionEnabled = NO; /* delete 処理がうまくいっていないため */
    
    return cell;
}

- (void)updateDeliverdCell:(MBIndividualMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.dateString = [self dateStringWithMessage:message];
    
    // MessageText
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE_MESSAGE];
    cell.tweetTextView.lineSpace = LINE_SPACING_MESSAGE;
    cell.tweetTextView.lineHeight = LINE_HEIGHT_MESSAGE;
    cell.tweetTextView.paragraphSpace = PARAGRAPH_SPACING_MESSAGE;
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]];
    CGRect longestRect = [self cellRectForMessage:message constraintSize:CGSizeMake(cell.maxTweetTextViewWidth, CGFLOAT_MAX)];

    [cell setTweetViewRect:longestRect];
    
    UIImage *partnerImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:message.sender.userIDStr];
    if (partnerImage) {
        CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:partnerImage size:avatorSize radius:4];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatorImageView.avatorImage = radiusImage;
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadOriginImageWithURL:message.sender.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:message.sender.userIDStr];
                CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
                UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:avatorSize radius:4];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatorImageView.avatorImage = radiusImage;
                });
            }failedHandler:^(NSURLResponse *response, NSError *error) {
                
            }];
        });
    }
}

- (void)updateSentCell:(MBIndividualMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBDirectMessage *message = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([message isKindOfClass:[MBTemporaryDirectMessage class]]) {
        cell.dateString= NSLocalizedString(@"Sending...", nil);
    } else {
        cell.dateString = [self dateStringWithMessage:message];
    }
    
    
    // messageText
    cell.tweetTextView.font = [UIFont systemFontOfSize:FONT_SIZE_MESSAGE];
    cell.tweetTextView.lineSpace = LINE_SPACING_MESSAGE;
    cell.tweetTextView.lineHeight = LINE_HEIGHT_MESSAGE;
    cell.tweetTextView.paragraphSpace = PARAGRAPH_SPACING_MESSAGE;
    cell.tweetTextView.textColor = [UIColor whiteColor];
    cell.tweetTextView.attributedString = [MBTweetTextComposer attributedStringForTweet:message tintColor:[self.navigationController.navigationBar tintColor]];
    
    [cell setPopsFromRight:YES];
    CGRect longestRect = [self cellRectForMessage:message constraintSize:CGSizeMake(cell.maxTweetTextViewWidth, CGFLOAT_MAX)];
    [cell setTweetViewRect:longestRect];
    
    
    UIImage *partnerImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:message.sender.userIDStr];
    if (partnerImage) {
        CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:partnerImage size:avatorSize radius:4];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatorImageView.avatorImage = radiusImage;
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MBImageDownloader downloadOriginImageWithURL:message.sender.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:message.sender.userIDStr];
                CGSize avatorSize = CGSizeMake(cell.avatorImageView.frame.size.height, cell.avatorImageView.frame.size.width);
                UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:avatorSize radius:4];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatorImageView.avatorImage = radiusImage;
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

#pragma mark UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    __weak id weak = self.keyboardToolbar;
    self.keyboardToolbar.textView.inputAccessoryView = weak;
    [self.keyboardToolbar.textView becomeFirstResponder];
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
        [self.view insertSubview:self.displayToolbar aboveSubview:self.tableView];
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
    [self.receiverTextField resignFirstResponder];
    [self.displayToolbar.textView resignFirstResponder];
    [self.keyboardToolbar.textView resignFirstResponder];
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

#pragma mark MBDirectMessageToolbarDelegate
- (void)toolbarDidChangeText:(MBDirectMessageToolbar *)toolbar
{
    self.displayToolbar.textView.text = toolbar.textView.text;
}

@end

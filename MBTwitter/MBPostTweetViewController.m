//
//  MBPostTweetViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBPostTweetViewController.h"

#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBTweetTextComposer.h"
#import "MBTweet.h"
#import "MBUserManager.h"
#import "MBUser.h"
#import "MBImageApplyer.h"
#import "MBPlace.h"

#import "MBReplyTextView.h"
#import "NSDictionary+Objects.h"
#import "MBGeoPinView.h"
#import "MBGradientMaskView.h"

@interface UIActionSheet(NonBecomeFirstResponder)
@end
@implementation UIActionSheet(NonBecomeFirstResponder)

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

@end



@interface MBPostTweetViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, readonly) CLLocationManager *locationManager;

@property (nonatomic, readonly) NSMutableArray *photos;
@property (nonatomic, readonly) NSMutableArray *replys;
@property (nonatomic, readonly) NSMutableDictionary *place;

@property (nonatomic, assign) BOOL showsImageView;

@property (nonatomic, readonly) NSString *tweetText;
@property (nonatomic) UIImage *compressingImage;

@property (nonatomic) MBGradientMaskView *geoPlaceView;
@property (nonatomic) MBGeoPinView *geoPinView;
@property (nonatomic) MBReplyTextView *replyTextView;
@property (nonatomic) UIBarButtonItem *postBarButtonitem;
@property (nonatomic) UIBarButtonItem *countBarButtonItem;
@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) UIBarButtonItem *photoButton;
@property (nonatomic) UIBarButtonItem *cameraButton;
@property (nonatomic) UIBarButtonItem *geoButton;
@property (nonatomic) UIBarButtonItem *suspendButton;

@end

@implementation MBPostTweetViewController
#pragma mark -
#pragma mark Initialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonConfigureModel];
    }
    return self;
}

- (void)common
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

#pragma mark -
#pragma mark Setter & Getteer
- (void)setText:(NSString *)text
{
    _tweetText = text;
}

- (void)setScreenName:(NSString *)screenName
{
    if (screenName && 0 < screenName.length) {
        NSString *screenNameAt = [NSString stringWithFormat:@"@%@ ", screenName];
        [self setText:screenNameAt];
        
        NSString *title = NSLocalizedString(@"Send to %@", nil);
        self.title = [NSString stringWithFormat:title, screenName];
    }
}

- (void)setRetweetWithComent:(NSString *)retweetedText tweetedUser:(NSString *)screenName
{
    if (retweetedText && 0 < retweetedText.length) {
        NSString *textWithRT = [NSString stringWithFormat:@" RT @%@: %@", screenName, retweetedText];
        [self setText:textWithRT];
        NSRange selectedRange = self.tweetTextView.selectedRange;
        selectedRange.length = 0;
        self.tweetTextView.selectedRange = selectedRange;
    }
}

- (void)setReferencedTweet:(MBTweet *)referencedTweet
{
    _referencedTweet = referencedTweet;
}

#pragma mark -
#pragma mark View
- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    
    _photos = [NSMutableArray arrayWithCapacity:4];
    _place = [NSMutableDictionary dictionaryWithCapacity:0];
    _replys = [NSMutableArray arrayWithCapacity:0];
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.showsImageView = NO;
    self.mediaImageView.backgroundColor = [UIColor lightGrayColor];
    [self applyConstraint];
    
    self.tweetTextView.alwaysBounceVertical = YES;
    self.tweetTextView.delegate = self;
}

- (void)commonConfigureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushCancelButton)];
    self.postBarButtonitem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didPushPostButton)];
    self.countBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.countBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[self.postBarButtonitem, self.countBarButtonItem];
    
    CGFloat barHeight = 44.0f; // 横向きには対応させないのでマジックナンバー
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, barHeight)];
    self.photoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Photo-Tool-1"] style:UIBarButtonItemStylePlain target:self action:@selector(didPushPhotoButton)];
    self.cameraButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Camera-Tool"] style:UIBarButtonItemStylePlain target:self action:@selector(didPushCameraButton)];
    self.geoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Geo-Line-Tool-1"] style:UIBarButtonItemStylePlain target:self action:@selector(didPushGeoButton)];
    self.suspendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Suspend", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushSuspendButton)];
    
    [self settingDefaultToolbarItemsWithAnimated:NO];
    
    self.tweetTextView.inputAccessoryView = self.toolbar;
}

- (void)settingToolBarItemWithAnimated:(BOOL)animated
{
    if (self.photos.count > 0 || self.place.allValues.count > 0) {
        [self settingCancelableToolbarItemsWithAnimated:animated];
    } else {
        [self settingDefaultToolbarItemsWithAnimated:animated];
    }
}

- (void)settingDefaultToolbarItemsWithAnimated:(BOOL)animated
{
    UIBarButtonItem *sparcer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttons = [NSArray arrayWithObjects:self.photoButton, sparcer, self.cameraButton, sparcer, self.geoButton, sparcer, sparcer, nil];
    
    [self.toolbar setItems:buttons animated:animated];
}

- (void)settingCancelableToolbarItemsWithAnimated:(BOOL)animated
{
    UIBarButtonItem *sparcer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttons = [NSArray arrayWithObjects:self.photoButton, sparcer, self.cameraButton, sparcer, self.geoButton, sparcer, self.suspendButton, nil];
    
    [self.toolbar setItems:buttons animated:animated];
}
/*
- (void)settingToolbarItems:(NSArray *)items animated:(BOOL)animated
{
    NSMutableArray *buttonItems = [NSMutableArray array];
    
    int i = 0;
    for (UIBarButtonItem *button in items) {
        if (i > 0) {
            UIBarButtonItem *sparcer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [buttonItems addObject:sparcer];
        }
        [buttonItems addObject:button];
        
        i ++;
    }
    UIBarButtonItem *sparcer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttonItems addObject:sparcer];
    [buttonItems addObject:self.suspendButton];
    
    [self.toolbar setItems:buttonItems animated:animated];
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonConfigureView];
    
    self.tweetTextView.text = self.tweetText;
    
    self.title = NSLocalizedString(@"New Tweet", nil);
    
    [self beEnableButtonForTextViewLength];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.tweetTextView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tweetTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tweetTextView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)addReply:(NSNumber *)replyID
{
    [self.replys addObject:replyID];
}

- (NSData *)compressedData64WithLimitLength:(NSUInteger)sizeLimit
{
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(self.compressingImage, compression);
    NSData *data64 = [imageData base64EncodedDataWithOptions:0];
    
    while (data64.length > sizeLimit && compression > maxCompression) {
        compression -=1;
        imageData = UIImageJPEGRepresentation(self.compressingImage, compression);
        data64 = [imageData base64EncodedDataWithOptions:0];
    }
    
    if (data64.length > sizeLimit) {
        return nil;
    }
    
    return data64;
}

- (void)showLocationAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alertView show];
}

#pragma mark
- (void)beEnableButtonForTextViewLength
{
    if (0 < self.tweetTextView.text.length && 140 >= self.tweetTextView.text.length) {
        [self.postBarButtonitem setEnabled:YES];
    } else if (0 < [self.photos count]) {
        [self.postBarButtonitem setEnabled:YES];
    }else {
        [self.postBarButtonitem setEnabled:NO];
    }
}

- (void)setCountOfBarButtonItem
{
    NSInteger textCount = self.tweetTextView.text.length;
    NSInteger tweetMax = 140;
    NSInteger mediaTextCount = self.photos.count * 23;
    
    NSInteger margin = tweetMax - textCount - mediaTextCount;
    if (0 <= margin) {
        self.countBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld", (long)margin] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.countBarButtonItem.enabled = NO;
        [self.navigationItem setRightBarButtonItems:@[self.postBarButtonitem, self.countBarButtonItem] animated:NO];
    } else if (0 > margin) {
        self.countBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld", (long)margin] style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.countBarButtonItem setTintColor:[UIColor redColor]];
        self.countBarButtonItem.enabled = YES;
        [self.navigationItem setRightBarButtonItems:@[self.postBarButtonitem, self.countBarButtonItem] animated:NO];
    }
}

- (NSInteger)countOfTweetText
{
    NSRange httpsRange = [self.tweetTextView.text rangeOfString:@"https"];
    NSLog(@"location %ld length %ld", (unsigned long)httpsRange.location, (unsigned long)httpsRange.length);
    return 0;
}

#pragma mark
- (void)applyConstraint
{
    if (self.showsImageView) {
        [self addImageViewConstraint];
    } else {
        [self removeImageViewConstraint];
    }
}

- (void)addImageViewConstraint
{
    self.topConstraint.constant = 12.0f + self.tweetTextView.contentInset.top;
    self.LeftHorizontalConstraint.constant = 4.0f;
    self.horizontalConstraint.constant = 10.0f;
    self.widthConstraint.constant = 64.0f;
    self.heightConstraint.constant = 64.0f;
}

- (void)removeImageViewConstraint
{
    self.topConstraint.constant = 0.0f;
    self.LeftHorizontalConstraint.constant = 0.0f;
    self.horizontalConstraint.constant = 0.0f;
    self.widthConstraint.constant = .0f;
    self.heightConstraint.constant = .0f;
}

#pragma mark
- (void)configurePinView
{
    if (self.geoPinView.superview) {
        [self.geoPinView removeFromSuperview];
    }
    
    CGRect initialRect = CGRectMake(0, 0, 32, 32);
    self.geoPinView = [[MBGeoPinView alloc] initWithFrame:initialRect];
    [self.view addSubview:self.geoPinView];
}

- (void)configureGeoPlaceViewWith:(MBPlace *)place
{
    if (self.geoPlaceView.superview) {
        [self.geoPlaceView removeFromSuperview];
    }
    
    CGSize geoPlaceViewSize = CGSizeMake(self.view.bounds.size.width, self.geoPinView.bounds.size.height + 8.0f);
    CGRect geoPlaceViewRect = CGRectMake(0, self.tweetTextView.frame.origin.y + self.tweetTextView.bounds.size.height - self.tweetTextView.contentInset.bottom - geoPlaceViewSize.height, geoPlaceViewSize.width, geoPlaceViewSize.height);
    self.geoPlaceView = [[MBGradientMaskView alloc] initWithFrame:geoPlaceViewRect];
    self.geoPlaceView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.99 alpha:0.9];
    self.geoPlaceView.startGradientPoint = CGPointMake(0.0f, 0.1f);
    self.geoPlaceView.endGradientPoint = CGPointMake(0.0f, 0.0f);
    [self.geoPlaceView maskGradient];
    [self.view insertSubview:self.geoPlaceView belowSubview:self.geoPinView];
    
    UILabel *geoPlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.geoPinView.bounds.size.width, 6.0, self.view.bounds.size.width - self.geoPinView.bounds.size.width, self.geoPlaceView.bounds.size.height)];
    NSString *fromPlace = NSLocalizedString(@"From %1$@, %2$@", nil);
    geoPlaceLabel.text = [NSString stringWithFormat:fromPlace, place.countryName, place.countryFullName];
    geoPlaceLabel.textColor = [UIColor darkGrayColor];
    geoPlaceLabel.font = [UIFont systemFontOfSize:15.0f];
    
    self.geoPlaceView.alpha = 0.0f;
    [self.geoPlaceView addSubview:geoPlaceLabel];
    
}

- (void)showGeoPlaceView:(BOOL)shows animated:(BOOL)animated
{
    CGFloat alpha = (shows) ? 1.0f : 0.0f;
    CGFloat duration = (animated) ? 0.3f : 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        self.geoPlaceView.alpha = alpha;
    }completion:^(BOOL finished) {
        if (!shows) {
            [self.geoPlaceView removeFromSuperview];
        }
    }];
}

- (void)placePinView
{
    CGFloat pinMargin = 4.0f;
    CGRect initialRect = self.geoPinView.frame;
    CGRect placedRect = initialRect;
    placedRect.origin.y = self.tweetTextView.frame.origin.y + self.tweetTextView.bounds.size.height - self.tweetTextView.contentInset.bottom - initialRect.size.height - pinMargin;
    self.geoPinView.frame = placedRect;
}

- (void)placePinViewWithBottomHeight:(CGFloat)BottomHeight
{
    CGFloat pinMargin = 4.0f;
    CGRect placedRect = self.geoPinView.frame;
    placedRect.origin.y = self.view.bounds.size.height - BottomHeight - self.geoPinView.bounds.size.height - pinMargin;
    self.geoPinView.frame = placedRect;
}

- (void)placeGeoPlaceViewWithBottomHeight:(CGFloat)BottomHeight
{
    CGRect geoPlaceRect = self.geoPlaceView.frame;
    geoPlaceRect.origin.y = self.view.bounds.size.height - BottomHeight - geoPlaceRect.size.height;
    self.geoPlaceView.frame = geoPlaceRect;
}

- (void)showingAnimatePinView
{
    [UIView animateWithDuration:0.3f animations:^{
        [self placePinView];
        
        CGFloat pinHeight = self.geoPinView.frame.size.height;
        UIEdgeInsets contentInsets = self.tweetTextView.contentInset;
        UIEdgeInsets scrollIndicatorInsets = self.tweetTextView.scrollIndicatorInsets;
        contentInsets.bottom += pinHeight;
        scrollIndicatorInsets.bottom += pinHeight;
        self.tweetTextView.contentInset = contentInsets;
        self.tweetTextView.scrollIndicatorInsets = scrollIndicatorInsets;
        
    }completion:^(BOOL finished) {
        [self.geoPinView boundingAnimateDotWithCompletion:^(){
            [self showGeoPlaceView:YES animated:YES];
        }];
        
    }];
}

- (void)hidingAnimatePinView
{
    [self showGeoPlaceView:NO animated:YES];
    
    [UIView animateWithDuration:0.1f animations:^{
        [self.geoPinView contractView];
        
        
        CGFloat pinHeight = self.geoPinView.frame.size.height;
        UIEdgeInsets contentInsets = self.tweetTextView.contentInset;
        UIEdgeInsets scrollIndicatorInsets = self.tweetTextView.scrollIndicatorInsets;
        contentInsets.bottom -= pinHeight;
        scrollIndicatorInsets.bottom -= pinHeight;
        self.tweetTextView.contentInset = contentInsets;
        self.tweetTextView.scrollIndicatorInsets = scrollIndicatorInsets;
        
    }completion:^ (BOOL finished) {
        [self.geoPinView scallingAnimateDotWithCompletion:^{
            [self.geoPinView removeFromSuperview];
            
        }];
    }];
}

#pragma mark notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]; /* カテゴリは unsignd ll でやっているので、objectFor~で */
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    
    UIEdgeInsets contentInsets = self.tweetTextView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tweetTextView.scrollIndicatorInsets;
    CGFloat bottomInset = size.height;
    if (self.geoPinView.superview || self.geoPlaceView.superview) {
        bottomInset += self.geoPinView.bounds.size.height;
    }
    contentInsets.bottom = bottomInset;
    scrollIndicatorInsets.bottom = bottomInset;
    
    
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tweetTextView.contentInset = contentInsets;
        self.tweetTextView.scrollIndicatorInsets = scrollIndicatorInsets;
        
        [self placePinViewWithBottomHeight:size.height];
        [self placeGeoPlaceViewWithBottomHeight:size.height];
        
    }completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInsets = self.tweetTextView.contentInset;
    UIEdgeInsets scrollIndicator = self.tweetTextView.scrollIndicatorInsets;
    contentInsets.bottom = 0;
    scrollIndicator.bottom = 0;
    
    
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tweetTextView.contentInset = contentInsets;
        self.tweetTextView.scrollIndicatorInsets = scrollIndicator;
        
    }completion:nil];
}

#pragma mark Button Action
- (void)dismissMe
{
    if ([_delegate respondsToSelector:@selector(dismissPostTweetViewController:animated:)]) {
        [_delegate dismissPostTweetViewController:self animated:YES];
    }
}

- (void)didPushPostButton
{
    if (self.tweetTextView.hasText || self.photos.count > 0) {
        if ([_delegate respondsToSelector:@selector(sendTweetPostTweetViewController:tweetText:replys:place:media:)]) {
            [_delegate sendTweetPostTweetViewController:self tweetText:self.tweetTextView.text replys:self.replys place:self.place media:self.photos];
        }
    }
}

- (void)didPushCancelButton
{
    [self dismissMe];
}

- (void)didPushSuspendButton
{
    NSString *firstTitle = NSLocalizedString(@"Cancellation of Image", nil);
    NSString *secondTitle = nil;
    if (self.photos.count > 0 && self.place.allValues.count > 0) {
        secondTitle = NSLocalizedString(@"Cancellation of Location", nil);
    } else if (self.photos.count == 0 && self.place.allValues.count > 0) {
        firstTitle = NSLocalizedString(@"Cancellation of Location", nil);
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Cancellation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:firstTitle, secondTitle, nil];
    [actionSheet showInView:self.view];
}

- (void)didPushPhotoButton
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        
    }
}

- (void)didPushCameraButton
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        
    }
}

- (void)cancelAttachedImage
{
    [self.photos removeAllObjects];
    self.showsImageView = NO;
    [self applyConstraint];
    [self setCountOfBarButtonItem];
    [self settingToolBarItemWithAnimated:YES];
}

- (void)didPushGeoButton
{
    MBAccount *currentAccount = [[MBAccountManager sharedInstance] currentAccount];
    MBUser *currenUser = [[MBUserManager sharedInstance] storedUserForKey:currentAccount.userID];
    if (!currenUser) {
        [self.aoAPICenter getUser:0 screenName:currentAccount.screenName];
        return;
    }
    
    BOOL isEnabledGeo = currenUser.isEnabledGeo;
    if (!isEnabledGeo) {
        [self showLocationAlertViewWithTitle:NSLocalizedString(@"Twitter Setting", nil) message:NSLocalizedString(@"Go Twitter. Be Enabled Twitter's Location Service.", nil)];
        return;
    }
    
    BOOL locationEnabled = [CLLocationManager locationServicesEnabled];
    if (locationEnabled == NO) {
        [self showLocationAlertViewWithTitle:NSLocalizedString(@"Location Service is Disabled.", nil) message:NSLocalizedString(@"Check Network, Restriction or Privacy.", nil)];
        return;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = 500; // meters
    
}

- (void)didPushCancelGeoButton
{
    [self.place removeAllObjects];
    
    if (self.geoPinView.superview) {
        [self hidingAnimatePinView];
        [self setGeoButtonWithTappable:YES];
        [self settingToolBarItemWithAnimated:YES];
    }
}

- (void)setGeoIndicatorButton
{
    UIBarButtonItem *geoIndicatorButton = [self animatingIndicatorButton];
    self.geoButton = geoIndicatorButton;
    
    [self settingDefaultToolbarItemsWithAnimated:NO];
}

- (void)setGeoButtonWithTappable:(BOOL)tappable
{
    UIBarButtonItem *geoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Geo-Line-Tool"] style:UIBarButtonItemStylePlain target:self action:@selector(didPushGeoButton)];
    geoButton.enabled = tappable;
    
    self.geoButton = geoButton;
}

/* unused */
- (void)setCameraAndPhotoButton
{
    BOOL enabled = YES;
    if (self.photos.count > 0) {
        enabled = NO;
    }
    
    self.cameraButton.enabled = enabled;
    self.photoButton.enabled = enabled;
}

- (UIBarButtonItem *)animatingIndicatorButton
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [indicatorView sizeToFit];
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicatorView startAnimating];
    UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    return indicatorButton;
    
}

#pragma mark -
#pragma mark TextView Delegate
/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self beEnableButtonForTextViewLength];
    [self setCountOfBarButtonItem];
    
    return YES;
}*/

- (void)textViewDidChange:(UITextView *)textView
{
    [self beEnableButtonForTextViewLength];
    [self setCountOfBarButtonItem];
}

#pragma mark ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float currentOffset = scrollView.contentOffset.y;
    if (0 > currentOffset) {
        if (!self.replyTextView.superview && self.referencedTweet) {
            if (NSOrderedSame == [self.referencedTweet.tweetID compare:[self.replys firstObject]]) {
                MBTweet *tweet = self.referencedTweet;
                if (!tweet) {
                    return;
                }
                NSAttributedString *attributedTweetText = [MBTweetTextComposer attributedStringForTweet:tweet tintColor:[UIColor lightGrayColor]];
                NSString *tweetText = [attributedTweetText string];
                NSString *sourceTweetText = [NSString stringWithFormat:@"@%@: %@", tweet.tweetUser.screenName, tweetText];
                UITextView *sizingTextView = [[UITextView alloc] init];
                sizingTextView.text = sourceTweetText;
                CGSize fitSize = [sizingTextView sizeThatFits:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)];
                
                /* replyText はいちいち初期化するべきではないと思う。 */
                self.replyTextView = [[MBReplyTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , fitSize.height)];
                CGRect textFrame = self.replyTextView.frame;
                textFrame.origin.y -= textFrame.size.height;
                self.replyTextView.frame = textFrame;
                self.replyTextView.text = sourceTweetText;
                [self.tweetTextView addSubview:self.replyTextView];
            }
            
        }
    } else {
        if (self.replyTextView.superview) {
            [self.replyTextView removeFromSuperview];
        }
    }
}

#pragma mark -
#pragma mark ImagePickerViewController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (nil == selectedImage) {
        return;
    }
    self.mediaImageView.image = nil;
    [self settingCancelableToolbarItemsWithAnimated:YES];
    self.compressingImage = selectedImage;
    self.showsImageView = YES;
    [self applyConstraint];
    self.postBarButtonitem.enabled = NO;
    
    [self.aoAPICenter getHelpConfiguration];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark AOuth_APICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedPlaces:(NSArray *)places
{
    MBPlace *place = [places firstObject];
    if (place) {
        [self setGeoButtonWithTappable:NO];
        [self settingCancelableToolbarItemsWithAnimated:YES];
        [self configurePinView];
        [self configureGeoPlaceViewWith:place];
        
        [self showingAnimatePinView];
    } else {
        [self setGeoButtonWithTappable:YES];
        [self settingDefaultToolbarItemsWithAnimated:YES];
    }
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users
{
    MBUser *gotUser = [users firstObject];
    if (gotUser) {
        [self didPushCameraButton];
    }
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets
{
    MBTweet *postedTweet = [tweets firstObject];
    if (postedTweet) {
        if ([_delegate respondsToSelector:@selector(sendTweetPostTweetViewController:)]) {
            [_delegate sendTweetPostTweetViewController:self];
        }
        
        
        if ([_delegate respondsToSelector:@selector(dismissPostTweetViewController:animated:)]) {
            [_delegate dismissPostTweetViewController:self animated:YES];
        }
    }
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center maxMedias:(NSNumber *)medias photoSizeLimit:(NSNumber *)photoSizeLimit shortURLLength:(NSNumber *)number
{
    if (!medias || !photoSizeLimit || !self.compressingImage) {
        self.compressingImage = nil;
        self.showsImageView = NO;
        [self applyConstraint];
        [self removeImageViewConstraint];
        self.postBarButtonitem.enabled = YES;
        return;
    }
    
    __weak MBPostTweetViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSData *imageData64 = [self compressedData64WithLimitLength:[photoSizeLimit unsignedIntegerValue]];
        if (!imageData64) {
            return ;
        }

        /* current media limit is 1... */
        if (weakSelf.photos.count > 0) {
            [weakSelf.photos removeAllObjects];
        }
        [weakSelf.photos addObject:imageData64];
        UIImage *resizedImage = [MBImageApplyer imageForTwitter:self.compressingImage size:CGSizeMake(weakSelf.mediaImageView.frame.size.width, weakSelf.mediaImageView.frame.size.height) radius:0.0f];
        self.compressingImage = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.mediaImageView.image = resizedImage;
            [weakSelf beEnableButtonForTextViewLength];
            [weakSelf setCountOfBarButtonItem];
        });
    });
}

#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"位置情報");
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        [self startUpdationgLocationForiOS8WithStatus:status];
    } else {
        [self startUpdationgLocationWithStatus:status];
    }
}

- (void)startUpdationgLocationWithStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self setGeoIndicatorButton];
        [self.locationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusAuthorized) {
        [self setGeoIndicatorButton];
        [self.locationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusRestricted) {
        [self showLocationAlertViewWithTitle:NSLocalizedString(@"Location Service is Restricted.", nil) message:NSLocalizedString(@"Setting > General > Restriction > Location Service. Uncheck this App.", nil)];
        [self setGeoButtonWithTappable:YES];
        
    } else if (status == kCLAuthorizationStatusDenied) {
        [self showLocationAlertViewWithTitle:NSLocalizedString(@"Location Service is Disabled.", nil) message:NSLocalizedString(@"Setting > Privacy > Location. Set enable this App.", nil)];
        [self setGeoButtonWithTappable:YES];
    }
}

- (void)startUpdationgLocationForiOS8WithStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        
    } else if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self setGeoIndicatorButton];
        [self.locationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusRestricted) {
        [self showLocationAlertViewWithTitle:NSLocalizedString(@"Location Service is Restricted.", nil) message:NSLocalizedString(@"Setting > General > Restriction > Location Service. Uncheck this App.", nil)];
        [self setGeoButtonWithTappable:YES];
        
    } else if (status == kCLAuthorizationStatusDenied) {
        [self showLocationAlertViewWithTitle:NSLocalizedString(@"Location Service is Disabled.", nil) message:NSLocalizedString(@"Setting > Privacy > Location. Set enable this App.", nil)];
        [self setGeoButtonWithTappable:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (0 < [locations count]) {
        CLLocation *latestLocation = [locations lastObject];
        float longitude = latestLocation.coordinate.longitude;
        float latitude = latestLocation.coordinate.latitude;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.minimumFractionDigits = 6;
        NSNumber *longitudeNumber = [NSNumber numberWithFloat:longitude];
        NSNumber *latitudeNumber = [NSNumber numberWithFloat:latitude];
        NSString *longitudeStr = [formatter stringFromNumber:longitudeNumber];
        NSString *latitudeStr = [formatter stringFromNumber:latitudeNumber];
        
        NSDictionary *place = @{@"longi": longitudeStr, @"lati": latitudeStr};
        [self.place setObject:place forKey:@"place"];
        [self.locationManager stopUpdatingLocation];
        
        
        [self.aoAPICenter getReverseGeocode:latitude longi:longitude];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error) {
        NSInteger errorCode = [error code];
        if (errorCode == kCLErrorDenied) {
            [self showLocationAlertViewWithTitle:NSLocalizedString(@"Location Service is Disabled.", nil) message:NSLocalizedString(@"Setting > Privacy > Location. Set enable this App.", nil)];
            
        } else if (errorCode == kCLErrorNetwork) {
            [self showLocationAlertViewWithTitle:NSLocalizedString(@"Netwotk Error.", nil) message:NSLocalizedString(@"Check Network Status. Try Again.", nil)];
        }
    }
    [self settingToolBarItemWithAnimated:YES];
}

#pragma mark UIActionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        ;
    } else if (buttonIndex == 0) {
        if (self.photos.count > 0) {
            [self cancelAttachedImage];
            [self beEnableButtonForTextViewLength];
        } else {
            [self didPushCancelGeoButton];
        }
        
    } else if (buttonIndex == 1) {
        [self didPushCancelGeoButton];
    }
}

@end

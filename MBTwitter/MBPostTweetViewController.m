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

#import "MBReplyTextView.h"
#import "NSDictionary+Objects.h"

@interface MBPostTweetViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, readonly) CLLocationManager *locationManager;

@property (nonatomic, readonly) NSMutableArray *photos;
@property (nonatomic, readonly) NSMutableArray *replys;
@property (nonatomic, readonly) NSMutableDictionary *place;

@property (nonatomic, assign) BOOL showsImageView;

@property (nonatomic, readonly) NSString *tweetText;

@property (nonatomic) MBReplyTextView *replyTextView;
@property (nonatomic) UIBarButtonItem *postBarButtonitem;
@property (nonatomic) UIBarButtonItem *countBarButtonItem;
@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) UIBarButtonItem *photoButton;
@property (nonatomic) UIBarButtonItem *cameraButton;
@property (nonatomic) UIBarButtonItem *geoButton;

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
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
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
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, barHeight)];
    self.photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(didPushPhotoButton)];
    self.cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(didPushCameraButton)];
    self.geoButton = [[UIBarButtonItem alloc] initWithTitle:@"Geo" style:UIBarButtonItemStylePlain target:self action:@selector(didPushGeoButton)];
    
    UIBarButtonItem *sparcer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttons = [NSArray arrayWithObjects:self.photoButton, self.cameraButton, self.geoButton, sparcer, nil];
    [self.toolbar setItems:buttons];
    [self.view addSubview:self.toolbar];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonConfigureView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tweetTextView.text = self.tweetText;
    [self beEnableButtonForTextViewLength];
    
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

- (void)beEnableButtonForTextViewLength
{
    if (0 == self.tweetTextView.text.length || 140 < self.tweetTextView.text.length) {
        [self.postBarButtonitem setEnabled:NO];
    }else if (0 < [self.photos count]) {
        [self.postBarButtonitem setEnabled:YES];
    }else {
        [self.postBarButtonitem setEnabled:YES];
    }
}

- (void)setCountOfBarButtonItem
{
    NSInteger textCount = self.tweetTextView.text.length;
    NSInteger tweetMax = 140;
    NSInteger margin = tweetMax - textCount;
    if (0 <= margin) {
        self.countBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d", margin] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.countBarButtonItem.enabled = NO;
        [self.navigationItem setRightBarButtonItems:@[self.postBarButtonitem, self.countBarButtonItem] animated:NO];
    } else if (0 > margin) {
        self.countBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d", margin] style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.countBarButtonItem setTintColor:[UIColor redColor]];
        self.countBarButtonItem.enabled = YES;
        [self.navigationItem setRightBarButtonItems:@[self.postBarButtonitem, self.countBarButtonItem] animated:NO];
    }
}

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

#pragma mark notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]; /* カテゴリは unsignd ll でやっているので、objectFor~で */
    unsigned int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInsets = self.tweetTextView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tweetTextView.scrollIndicatorInsets;
    contentInsets.bottom = size.height + self.toolbar.frame.size.height;
    scrollIndicatorInsets.bottom = size.height + self.toolbar.frame.size.height;
    
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height - (size.height + toolbarFrame.size.height);
    
    duration += 0.5;
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tweetTextView.contentInset = contentInsets;
        self.tweetTextView.scrollIndicatorInsets = scrollIndicatorInsets;
        
        self.toolbar.frame = toolbarFrame;
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
    
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height;
    
    duration -= 0.1;
    [UIView animateWithDuration:duration delay:0.0f options:curve animations:^{
        self.tweetTextView.contentInset = contentInsets;
        self.tweetTextView.scrollIndicatorInsets = scrollIndicator;
        
        self.toolbar.frame = toolbarFrame;
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
    if (self.tweetTextView.hasText) {
        [self.aoAPICenter getHelpConfiguration];
        
        [self.aoAPICenter postTweet:self.tweetTextView.text inReplyTo:self.replys place:self.place media:self.photos];
    }
}

- (void)didPushCancelButton
{
    [self dismissMe];
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
        NSLog(@"Twitter の設定で位置情報を ON にしろ。");
        return;
    }
    
    BOOL locationEnabled = [CLLocationManager locationServicesEnabled];
    if (YES == locationEnabled) {
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusNotDetermined: {
                [self.locationManager startUpdatingLocation];
            }
                break;
            case kCLAuthorizationStatusAuthorized: {
                [self.locationManager startUpdatingLocation];
            }
                break;
            case kCLAuthorizationStatusRestricted: {
                NSLog(@"位置情報サービス機能が制限されています。");
            }
                break;
            case kCLAuthorizationStatusDenied: {
                NSLog(@"プライバシー＞位置情報サービスをオン、MurmurBird をオンにしろ");
            }
                break;
            default:
                break;
        }
        
    } else {
        NSLog(@"プライバシー＞位置情報サービスをオンにしろ");
    }
}

#pragma mark -
#pragma mark TextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self beEnableButtonForTextViewLength];
    [self setCountOfBarButtonItem];
    
    return YES;
}

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
                
                self.replyTextView = [[MBReplyTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, fitSize.height)];
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
    
    self.showsImageView = YES;
    [self applyConstraint];
    self.postBarButtonitem.enabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imageData = UIImagePNGRepresentation(selectedImage);
        NSData *data64 = [imageData base64EncodedDataWithOptions:0];
        [self.photos addObject:data64];
        UIImage *resizedImage = [MBImageApplyer imageForTwitter:selectedImage byScallingAspectFillSize:CGSizeMake(self.mediaImageView.frame.size.width, self.mediaImageView.frame.size.height) radius:0.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mediaImageView.image = resizedImage;
            self.postBarButtonitem.enabled = YES;
        });
    });
    
    
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
    
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users
{
    MBUser *gotUser = [users firstObject];
    if (gotUser) {
        [self didPushCameraButton];
    }
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
{
    MBTweet *postedTweet = [tweets firstObject];
    if (postedTweet) {
        if ([_delegate respondsToSelector:@selector(dismissPostTweetViewController:animated:)]) {
            [_delegate dismissPostTweetViewController:self animated:YES];
        }
    }
}

#pragma mark CLLocationManager Delegate
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
        
        [self.aoAPICenter getReverseGeocode:longitude longi:latitude];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error) {
        NSString *message = nil;
        NSInteger errorCode = [error code];
        switch (errorCode) {
            case kCLErrorDenied: {
                NSLog(@"位置情報サービスがオンになってない");
            }
                break;
            case kCLErrorNetwork: {
                NSLog(@"ネットワークエラー");
            }
                break;
                
            default:
                break;
        }
    }
}

@end

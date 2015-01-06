//
//  MBImageViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/06.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBImageViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MBUser.h"
#import "MBTweet.h"
#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"

#import "MBAvatorImageView.h"
#import "MBSeparateLineView.h"

@interface MBImageViewController ()

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, assign) BOOL hiddenViews;

@property (nonatomic, readonly) UIImageView *imageView;

@end

@implementation MBImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Setter & Getter
- (void)setMediaIDStr:(NSString *)mediaIDStr
{
    _mediaIDStr = mediaIDStr;
}

- (void)setImageURLString:(NSString *)imageURLString
{
    _imageURLString = imageURLString;
}

- (void)setTweet:(MBTweet *)tweet
{
    _tweet = tweet;
}

- (void)setMediaImage:(UIImage *)mediaImage
{
    _mediaImage = mediaImage;
}

#pragma mark - View
- (void)configureNabigationItem
{
    [self.closeButton addTarget:self action:@selector(didPushBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton setImage:[UIImage imageNamed:@"Action"] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(didPushActionButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
}

- (void)configureView
{
    [self configureNabigationItem];
    [self configureTweetView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.imageView];
    
    self.hiddenViews = NO;
    
    self.scrollView.delegate = self;
    
    [self.tapGestureRecognizer addTarget:self action:@selector(didTapGesture)];
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubletapGestureRecognizer];
    [self.doubletapGestureRecognizer addTarget:self action:@selector(didDoubleTapGesture)];
}

- (void)downloadMediaImage
{
    if (!self.imageURLString && !self.mediaIDStr) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [MBImageDownloader downloadMediaImageWithURL:self.imageURLString completionHandler:^(UIImage *image, NSData *imageData) {
            [[MBImageCacher sharedInstance] storeMediaImage:image data:imageData forMediaID:self.mediaIDStr];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _mediaImage = image;
                [self renewViews];
            });
            
        }failedHandler:^(NSURLResponse *response, NSError *error) {
            
        }];
    });
}

- (void)configureTweetView
{
    MBUser *user = self.tweet.tweetUser;
    self.characterNameLabel.text = user.characterName;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    
    // setting Tweet
    self.tweetTextView.text = self.tweet.tweetText;
    self.tweetTextView.font = [UIFont systemFontOfSize:15.0f];
    self.tweetTextView.textColor = [UIColor whiteColor];
    CGSize textViewSize = [self.tweetTextView sizeThatFits:CGSizeMake(self.tweetTextView.frame.size.width, CGFLOAT_MAX)];
    
    CGRect textViewRect = self.tweetTextView.frame;
    textViewRect.size = textViewSize;
    self.tweetTextView.frame = textViewRect;
    
    CGRect tweetContainerViewRect = self.tweetContainerView.frame;
    tweetContainerViewRect.size.height = self.tweetTextView.frame.size.height + (26.0f + 50.0f);
    self.tweetContainerView.frame = tweetContainerViewRect;
    // gradient mask
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.tweetContainerView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(0.0f, 0.2f);
    gradientLayer.endPoint = CGPointMake(0.0f, 0.0f);
    self.tweetContainerView.layer.mask = gradientLayer;
    self.tweetContainerView.startPoint = CGPointMake(self.avatorImageView.frame.origin.x, tweetContainerViewRect.size.height - 48);
    self.tweetContainerView.endPoint = CGPointMake(tweetContainerViewRect.size.width - self.avatorImageView.frame.origin.x, tweetContainerViewRect.size.height - 48);
    
    // setting or downloading Image
    self.avatorImageView.layer.cornerRadius = 2.0f;
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedTimelineImageForUser:user.userIDStr];
    if (!avatorImage) {
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(globalQueue, ^{
            [MBImageDownloader downloadOriginImageWithURL:user.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:user.userIDStr];
                    CGSize imageSize = CGSizeMake(self.avatorImageView.frame.size.width, self.avatorImageView.frame.size.height);
                    UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:self.avatorImageView.layer.cornerRadius];
                    [[MBImageCacher sharedInstance] storeTimelineImage:image forUserID:user.userIDStr];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.avatorImageView.image = radiusImage;
                    });
                }
                
            }failedHandler:^(NSURLResponse *response, NSError *error){
                
            }];
            
        });
    } else {
        self.avatorImageView.image = avatorImage;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureModel];
    [self configureTweetView];
    
    if (self.tweet.requireLoading || self.tweet.isRetweeted) {
        [self.aoAPICenter getTweet:[self.tweet.tweetID unsignedLongLongValue]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self configureView];
    [self renewViews];
    
    if (!self.mediaImage) {
        [self downloadMediaImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods
- (void)renewViews
{
    CGRect rect;
    CGRect bounds = self.view.bounds;
    
    rect.origin = CGPointZero;
    rect.size = bounds.size;
    
    self.scrollView.frame = rect;
    
    // reset scale
    self.scrollView.zoomScale = 1.0;
    self.imageView.transform = CGAffineTransformIdentity;
    
    rect.origin = CGPointZero;
    rect.size = self.mediaImage.size;
    self.imageView.frame = rect;
    self.imageView.image = self.mediaImage;

    self.scrollView.contentSize = self.mediaImage.size;
    
    
    // setting scale
    float hScale, vScale, minScale, maxScale;
    hScale = CGRectGetWidth(bounds) / self.mediaImage.size.width;
    vScale = CGRectGetHeight(bounds) / self.mediaImage.size.height;

    /*
    BOOL imagePortrait = self.mediaImage.size.height > self.mediaImage.size.width;
    BOOL phonePortrait = bounds.size.height > bounds.size.width;
    minScale = imagePortrait == phonePortrait ? hScale : MIN(hScale, vScale);*/
    minScale = MIN(hScale, vScale);
    maxScale = [[UIScreen mainScreen] scale];
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.zoomScale = minScale;
    
    [self updateImageViewCenter];
}

- (void)updateImageViewCenter
{
    UIImage *image;
    CGSize imageSize;
    image = self.imageView.image;
    imageSize = image.size;
    imageSize.width *= self.scrollView.zoomScale;
    imageSize.height *= self.scrollView.zoomScale;
    
    CGRect bounds;
    bounds = self.scrollView.bounds;
    
    // calculate imageView's center
    CGPoint point;
    point.x = imageSize.width * 0.5f;
    if (imageSize.width < CGRectGetWidth(bounds)) {
        point.x += (CGRectGetWidth(bounds) - imageSize.width) * 0.5f;
    }
    point.y = imageSize.height * 0.5f;
    if (imageSize.height < CGRectGetHeight(bounds)) {
        point.y += (CGRectGetHeight(bounds) - imageSize.height) * 0.5f;
    }
    self.imageView.center = point;
}

#pragma mark Action
- (void)didPushActionButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Save Image", nil), nil];
    [actionSheet showInView:self.view];
}

- (void)didPushBackButton
{
    if ([_delegate respondsToSelector:@selector(dismissImageViewController:)]) {
        [_delegate dismissImageViewController:self];
    }
}

- (void)didTapGesture
{
    BOOL isHidden = (self.hiddenViews) ? NO : YES;
    CGFloat alpha = (self.hiddenViews) ? 1.0f : 0.0f;
    
    [UIView animateWithDuration:0.1f delay:0 options:0 animations:^{
        self.tweetContainerView.alpha = alpha;
        [self.navigationController setNavigationBarHidden:isHidden];
        
    }completion:^(BOOL finished){
        self.hiddenViews = isHidden;
    }];
}

- (void)didDoubleTapGesture
{
    BOOL zooming = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) ? YES : NO;
    CGFloat zoomingScale = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
    
    if (zooming) {
        UIView *zoomingView = [self viewForZoomingInScrollView:self.scrollView];
        CGPoint tapPoint = [self.doubletapGestureRecognizer locationInView:zoomingView];
        [self.scrollView zoomToRect:CGRectMake(tapPoint.x, tapPoint.y, self.view.bounds.size.width, self.view.bounds.size.height) animated:YES];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.scrollView.zoomScale = zoomingScale;
        }];
    }
}

#pragma mark -
#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets
{
    MBTweet *parsedTweet = [tweets firstObject];
    if (parsedTweet) {
        [self setTweet:parsedTweet];
        [self configureTweetView];
    }
}

#pragma mark UIScrollViewController Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    for (UIView *subView in scrollView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            
            return subView;
        }
    }
    
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateImageViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self updateImageViewCenter];
}

#pragma mark ActionsheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        
    } else if (0 == buttonIndex) {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(completionSelectorSavingImage:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)completionSelectorSavingImage:(UIImage *) image
didFinishSavingWithError: (NSError *) error
contextInfo: (void *) contextInfo;
{
    
    if (error) {
        ;
    } else {
        
    }
}

@end

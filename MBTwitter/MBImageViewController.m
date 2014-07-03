//
//  MBImageViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/06.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBImageViewController.h"

#import "MBUser.h"
#import "MBTweet.h"
#import "MBImageCacher.h"
#import "MBImageDownloader.h"

#import "MBAvatorImageView.h"

@interface MBImageViewController ()

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, assign) BOOL hiddenViews;

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

#pragma mark - View
- (void)configureNabigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushBackButton)];
}

- (void)configureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
}

- (void)configureView
{
    [self configureNabigationItem];
    [self configureImageView];
    [self configureTweetView];
    
    self.hiddenViews = NO;
    
    self.scrollView.delegate = self;
    
    [self.tapGestureRecognizer addTarget:self action:@selector(didTapGesture)];
    [self.doubletapGestureRecognizer addTarget:self action:@selector(didDoubleTapGesture)];
}

- (void)configureImageView
{
    UIImage *mediaImage = [[MBImageCacher sharedInstance] cachedMediaImageForMediaID:self.mediaIDStr];
    _mediaImage = mediaImage;
    if (!self.mediaImage) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [MBImageDownloader downloadImageWithURL:self.imageURLString completionHandler:^(UIImage *image, NSData *imageData) {
                [[MBImageCacher sharedInstance] storeMediaImage:image data:imageData forMediaID:self.mediaIDStr];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _mediaImage = image;
                    self.imageView.image = self.mediaImage;
                    [self renewViews];
                });
                
            }failedHandler:^(NSURLResponse *response, NSError *error) {
                
            }];
        });
    } else {
        self.imageView.image = self.mediaImage;
        [self renewViews];
    }
}

- (void)configureTweetView
{
    MBUser *user = self.tweet.tweetUser;
    self.characterNameLabel.text = user.characterName;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    
    // setting Tweet
    self.tweetTextView.text = self.tweet.tweetText;
    self.tweetTextView.textColor = [UIColor whiteColor]; // IB ではなぜか設定が反映されない
    self.tweetTextView.font = [UIFont systemFontOfSize:15.0f];
    CGSize textViewSize = [self.tweetTextView sizeThatFits:CGSizeMake(self.tweetTextView.frame.size.width, CGFLOAT_MAX)];
    CGRect textViewRect = self.tweetTextView.frame;
    textViewRect.size = textViewSize;
    self.tweetTextView.frame = textViewRect;
    
    CGRect tweetContainerViewRect = self.tweetContainerView.frame;
    tweetContainerViewRect.size.height = self.tweetTextView.frame.size.height + (54.0f + 8.0f);
    self.tweetContainerView.frame = tweetContainerViewRect;
    
    // setting or downloading Image
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedTimelineImageForUser:user.userIDStr];
    if (!avatorImage) {
        ;
    } else {
        self.avatorImageView.image = avatorImage;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureModel];
    [self configureView];
    
    if (self.tweet.requireLoading || self.tweet.isRetweeted) {
        [self.aoAPICenter getTweet:[self.tweet.tweetID unsignedLongLongValue]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods
- (void)renewViews
{NSLog(@"renew");
    CGRect rect;
    
    rect.origin = CGPointZero;
    rect.size = self.view.frame.size;
    //self.imageView.frame = rect;
    
    //self.scrollView.frame = rect;
    
    // reset scale
    self.scrollView.zoomScale = 1.0;
    self.scrollView.transform = CGAffineTransformIdentity;
    
    rect.origin = CGPointZero;
    rect.size = self.mediaImage.size;
    self.imageView.frame = rect;
    
    self.scrollView.contentSize = self.mediaImage.size;
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentInset = UIEdgeInsetsZero;
    
    // setting scale
    float hScale, vScale, minScale;
    hScale = CGRectGetWidth(self.scrollView.bounds) / self.mediaImage.size.width;
    vScale = CGRectGetHeight(self.scrollView.bounds) / self.mediaImage.size.height;
    minScale = MIN(hScale, vScale);
    NSLog(@"minScale = %f", minScale);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.zoomScale = minScale;
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
    //self.imageView.center = point;
}

#pragma mark Action
- (IBAction)didPushActionButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Chancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Save Image", nil), nil];
    [actionSheet showFromToolbar:self.toolbar];
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
    UIColor *changedScrollViewBackgroundColor = (self.hiddenViews) ? [UIColor whiteColor] : [UIColor blackColor];
    
    [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
        [self.tweetContainerView setHidden:isHidden];
        self.toolbar.hidden = isHidden;
        [self.navigationController setNavigationBarHidden:isHidden];
        self.scrollView.backgroundColor = changedScrollViewBackgroundColor;
        
    }completion:^(BOOL finished){
        self.hiddenViews = isHidden;
    }];
}

- (void)didDoubleTapGesture
{
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.imageView.bounds.size;
}

#pragma mark -
#pragma mark AOuthAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedTweets:(NSArray *)tweets
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
        NSLog(@"save Image");
    }
}

@end

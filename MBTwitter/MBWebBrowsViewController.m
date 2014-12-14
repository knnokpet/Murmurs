//
//  MBWebBrowsViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/19.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBWebBrowsViewController.h"

#import "MBLoadingView.h"

@interface MBWebBrowsViewController ()

@property (nonatomic, readonly) MBLoadingView *loadingView;

@property (nonatomic, readonly) UIBarButtonItem *goBackBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *goForwardBarButtonItem;

@end

@implementation MBWebBrowsViewController
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

- (void)setUrlRequest:(NSURLRequest *)urlRequest
{
    _urlRequest = urlRequest;
}

#pragma mark -
#pragma mark View
- (void)configureView
{
    [self configureNavigationitem];
    
    self.webView.delegate = self;
}

- (void)configureLoadingView
{
    if (!self.loadingView.superview) {
        _loadingView = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.loadingView];
    }
}

- (void)configureNavigationitem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didPushDoneButton)];
    
    _goBackBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"goBack"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    _goForwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"goForward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *space3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[self.goBackBarButtonItem, self.goForwardBarButtonItem, space2, space3] animated:NO];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureView];
    
    self.title = NSLocalizedString(@"Loading...", nil);
    [self configureLoadingView];
    
    [self.webView loadRequest:self.urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)removeLoadingView
{
    if (self.loadingView.superview) {
        [self.loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

- (void)updateToolbar
{
    if (self.webView.canGoBack || self.webView.canGoForward) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    
    self.goBackBarButtonItem.enabled = self.webView.canGoBack;
    self.goForwardBarButtonItem.enabled = self.webView.canGoForward;
}

#pragma mark Action
- (void)didPushDoneButton
{
    if ([_delegate respondsToSelector:@selector(closeBrowsViewController:animated:)]) {
        [_delegate closeBrowsViewController:self animated:YES];
    }
}

- (void)goBack
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)goForward
{
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

#pragma mark - Delegate
#pragma mark UIWebView
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self updateToolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeLoadingView];

    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end

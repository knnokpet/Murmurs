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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

#pragma mark Action
- (void)didPushDoneButton
{
    if ([_delegate respondsToSelector:@selector(closeBrowsViewController:animated:)]) {
        [_delegate closeBrowsViewController:self animated:YES];
    }
}

#pragma mark - Delegate
#pragma mark UIWebView
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeLoadingView];
    
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end

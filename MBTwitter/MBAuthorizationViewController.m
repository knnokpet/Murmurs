//
//  MBAuthorizationViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAuthorizationViewController.h"
#import "OAAccessibility.h"

@interface MBAuthorizationViewController () <UIWebViewDelegate>

@end

@implementation MBAuthorizationViewController

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
#pragma mark View

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.webView.delegate = self;
}

- (void)commonConfigureNavigationItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didPushCancelButton)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonConfigureView];
    
    self.twitterAccesser.delegate = self;
    
    BOOL isAuthorized = [self.twitterAccesser isAuthorized];
    if (!isAuthorized) {
        [self.twitterAccesser requestRequestToken];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Action
- (void)didPushCancelButton
{
    if ([_delegate respondsToSelector:@selector(dismissAuthorizationViewController:animated:)]) {
        [_delegate dismissAuthorizationViewController:self animated:YES];
    }
}

#pragma mark Private Methods
- (NSString *)authPinInWebView: (UIWebView *)webView;
{
    NSString *javaScript = @"var elem = document.getElementById('oauth-pin'); if (elem == null) elem = document.getElementById('oauth_pin'); if(elem) var elem2 = elem.getElementsByTagName('code'); if (elem2.length > 0) elem2[0].innerHTML;";
    NSString *pin = [[webView stringByEvaluatingJavaScriptFromString:javaScript] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (pin.length == 7) {
        return pin;
    } else { // nil or new Version HTML

        if (pin.length == 7) {
            return pin;
        }
    }
    
    return nil;
}

- (void)gotPin:(NSString *)pin
{
    [self.twitterAccesser setPin:pin];
    [self.twitterAccesser requestAccessToken];
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

#pragma mark -
#pragma mark WebView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSString *pin = [self authPinInWebView:webView];
    if (pin) {
        [self gotPin:pin];
    }
}

#pragma mark MBTwitterAccesser Delegate
- (void)gotRequestTokenTwitterAccesser:(MBTwitterAccesser *)twitterAccesser
{
    NSURLRequest *authorizeURLRequest = [self.twitterAccesser authorizeURLRequest];
    [self.webView loadRequest:authorizeURLRequest];
}

- (void)gotAccessTokenTwitterAccesser:(MBTwitterAccesser *)twitterAccesser
{
    if ([_delegate respondsToSelector:@selector(succeedAuthorizationViewController:animated:)]) {
        [_delegate succeedAuthorizationViewController:self animated:YES];
    }
}

@end

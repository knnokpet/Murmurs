//
//  MBWebBrowsViewController.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/19.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBWebBrowsViewControllerDelegate;
@interface MBWebBrowsViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id <MBWebBrowsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, readonly) NSURLRequest *urlRequest;

- (void)setUrlRequest:(NSURLRequest *)urlRequest;

@end


@protocol MBWebBrowsViewControllerDelegate <NSObject>

- (void)closeBrowsViewController:(MBWebBrowsViewController *)controller animated:(BOOL)animated;

@end

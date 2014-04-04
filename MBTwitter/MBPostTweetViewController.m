//
//  MBPostTweetViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/04.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBPostTweetViewController.h"
#import "MBAOuth_TwitterAPICenter.h"

@interface MBPostTweetViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;

@end

@implementation MBPostTweetViewController
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tweetTextView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BUtton Action
- (void)dismissMe
{
    if ([_delegate respondsToSelector:@selector(dismissPostTweetViewController:animated:)]) {
        [_delegate dismissPostTweetViewController:self animated:YES];
    }
}

- (IBAction)didPushPostButton:(id)sender {
    [self.aoAPICenter postTweet:self.tweetTextView.text];
}

#pragma mark -
#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    
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

@end

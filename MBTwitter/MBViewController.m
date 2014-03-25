//
//  MBViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBViewController.h"
#import "MBMyAccountsViewController.h"

#import "MBTwitterAccesser.h"

#define CONSUMER_KEY    @"AosTsb1nT61TS292imejQ"
#define CONSUMER_SECRET @"L2h0eN7dIKon8OhkcwVJ7KFDUuMoFFkSFKd33auJA"


@interface MBViewController ()

@property (nonatomic) MBTwitterAccesser *twitterAccesser;

@property (weak, nonatomic) IBOutlet UIButton *authorizationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *accountButton;

@end

@implementation MBViewController

#pragma mark -
#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Action
- (IBAction)didPushAuthorizationButton:(id)sender {
    [self performSegueWithIdentifier:@"AuthorizationIdentifier" sender:self];
}

- (IBAction)didPushAccountButton:(id)sender {
    [self performSegueWithIdentifier:@"AccountIdentifier" sender:self];
}

#pragma mark -
#pragma mark StoryBoard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (YES == [[segue identifier] isEqualToString:@"AuthorizationIdentifier"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        MBAuthorizationViewController *authorizationController = (MBAuthorizationViewController *)navigationController.topViewController;
        authorizationController.delegate = self;
        self.twitterAccesser = [[MBTwitterAccesser alloc] init];
        [self.twitterAccesser setConsumerKey:CONSUMER_KEY];
        [self.twitterAccesser setConsumerSecret:CONSUMER_SECRET];
        authorizationController.twitterAccesser = self.twitterAccesser;
        
    } else if (YES == [[segue identifier] isEqualToString:@"AccountIdentifier"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        MBMyAccountsViewController *accountViewController = (MBMyAccountsViewController *)navigationController.topViewController;
        self.twitterAccesser = [[MBTwitterAccesser alloc] init];
        [self.twitterAccesser setConsumerKey:CONSUMER_KEY];
        [self.twitterAccesser setConsumerSecret:CONSUMER_SECRET];
        accountViewController.twitterAccessor = self.twitterAccesser;
    }
}

#pragma mark -
#pragma mark MBAuthorizationViewController Delegate
- (void)popAuthorizationViewController:(MBAuthorizationViewController *)controller animated:(BOOL)animated
{
    [controller dismissViewControllerAnimated:animated completion:nil];
}

@end

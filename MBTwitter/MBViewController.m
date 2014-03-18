//
//  MBViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBViewController.h"
#import "MBAuthorizationViewController.h"

#import "MBTwitterAccesser.h"

#define CONSUMER_KEY    @"0v5ijUEgBgoOorJMRhHIw"
#define CONSUMER_SECRET @"hUp7JgMXMecwdoWhUMxSmYE0j1cWnp9NRBtOsHso"

@interface MBViewController ()
@property (weak, nonatomic) IBOutlet UIButton *authorizationButton;

@end

@implementation MBViewController

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
- (IBAction)didPushAuthorizationButton:(id)sender {
    [self performSegueWithIdentifier:@"AuthorizationIdentifier" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AuthorizationIdentifier"]) {
        MBAuthorizationViewController *authorizationController = [segue destinationViewController];
        MBTwitterAccesser *accesser = [[MBTwitterAccesser alloc] init];
        [accesser setConsumerKey:CONSUMER_KEY];
        [accesser setConsumerSecret:CONSUMER_SECRET];
        authorizationController.twitterAccesser = accesser;
        
    }
}

@end

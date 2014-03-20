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

#define CONSUMER_KEY    @"AosTsb1nT61TS292imejQ"
#define CONSUMER_SECRET @"L2h0eN7dIKon8OhkcwVJ7KFDUuMoFFkSFKd33auJA"
//#define CONSUMER_KEY    @"MCD8BKwGdgPHvAuvgvz4EQpqDAtx89grbuNMRd7Eh98"
//#define CONSUMER_SECRET @"MCD8BKwGdgPHvAuvgvz4EQpqDAtx89grbuNMRd7Eh98"


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
    if (YES == [[segue identifier] isEqualToString:@"AuthorizationIdentifier"]) {
        MBAuthorizationViewController *authorizationController = [segue destinationViewController];
        MBTwitterAccesser *accesser = [[MBTwitterAccesser alloc] init];
        [accesser setConsumerKey:CONSUMER_KEY];
        [accesser setConsumerSecret:CONSUMER_SECRET];
        authorizationController.twitterAccesser = accesser;
        
    }
}

@end

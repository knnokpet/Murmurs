//
//  MBAuthorizationViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAuthorizationViewController.h"

@interface MBAuthorizationViewController ()

@end

@implementation MBAuthorizationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

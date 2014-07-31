//
//  MBAppDelegate.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAppDelegate.h"

#import "MBHomeTimelineViewController.h"
#import "MBReplyTimelineViewController.h"
#import "MBSeparatedDirectMessageUserViewController.h"
#import "MBMyListViewController.h"
#import "MBSearchViewController.h"

#import "MBAccountManager.h"
#import "MBTimeLineManager.h"

@implementation MBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.tabBarController = [[UITabBarController alloc] init];
    
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    [accountManager requestAccessToAccountWithCompletionHandler:^(BOOL granted, NSArray *accounts, NSError *error){
        
    }];
    
    // viewControllers
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:5];
    MBHomeTimelineViewController *homeViewController = [[MBHomeTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [viewControllers addObject:timelineNavigationController];
    UIImage *homeImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Timeline@2x" ofType:@"png"]];
    UIImage *homeSelectedImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Timeline-Selected@2x" ofType:@"png"]];
    UITabBarItem *homeBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", nil) image:homeImage selectedImage:homeSelectedImage];
    homeViewController.tabBarItem = homeBarItem;
    
    MBReplyTimelineViewController *replyTimelineViewController = [[MBReplyTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
    UINavigationController *replyNavigation = [[UINavigationController alloc] initWithRootViewController:replyTimelineViewController];
    [viewControllers addObject:replyNavigation];
    UIImage *replyImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"atmark@2x" ofType:@"png"]];
    UITabBarItem *replyBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Reply", nil) image:replyImage tag:1];
    replyTimelineViewController.tabBarItem = replyBarItem;
    
    MBSeparatedDirectMessageUserViewController *separatedDMUserViewController = [[MBSeparatedDirectMessageUserViewController alloc] initWithNibName:@"SeparatedDirectMessagesView" bundle:nil];
    UINavigationController *dmUserNavigation = [[UINavigationController alloc] initWithRootViewController:separatedDMUserViewController];
    [viewControllers addObject:dmUserNavigation];
    UIImage *messageImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Message-2@2x" ofType:@"png"]];
    UIImage *messageSelectedImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Message-Selected-2@2x" ofType:@"png"]];
    UITabBarItem *messageBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Message", nil) image:messageImage selectedImage:messageSelectedImage];
    separatedDMUserViewController.tabBarItem = messageBarItem;
    
    MBMyListViewController *myListViewController = [[MBMyListViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
    UINavigationController *listNavigation = [[UINavigationController alloc] initWithRootViewController:myListViewController];
    [viewControllers addObject:listNavigation];
    UIImage *listImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"List2@2x" ofType:@"png"]];
    UIImage *listSelectedImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"List-Selected-2@2x" ofType:@"png"]];
    UITabBarItem *listBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"List", nil) image:listImage selectedImage:listSelectedImage];
    myListViewController.tabBarItem = listBarItem;
    
    MBSearchViewController *searchViewController = [[MBSearchViewController alloc] init];
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [viewControllers addObject:searchNavigationController];
    UITabBarItem *searchItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:5];
    searchViewController.tabBarItem = searchItem;
    
    self.tabBarController.viewControllers = viewControllers;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    MBHomeTimelineViewController *homeViewController = nil;
    id obj = [self.tabBarController.viewControllers firstObject];
    if ([obj isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = obj;
        id objInNavigation = [navigationController.viewControllers firstObject];
        if ([objInNavigation isKindOfClass:[MBHomeTimelineViewController class]]) {
            homeViewController = objInNavigation;
        }
    }
    [[MBTweetManager sharedInstance] deleteAllSavedTweetsOfCurrentAccount];
    [homeViewController saveTimeline];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    for (UINavigationController *navigationController in self.tabBarController.viewControllers) {
        id rootViewController = [navigationController.viewControllers firstObject];
        if ([rootViewController isKindOfClass:[MBHomeTimelineViewController class]]) {
            MBHomeTimelineViewController *timelineViewController = rootViewController;
            [timelineViewController refreshAction];
            [timelineViewController refreshMyAccountUser];
            
        } else if ([rootViewController isKindOfClass:[MBReplyTimelineViewController class]]) {
            MBReplyTimelineViewController *replyViewController = rootViewController;
            [replyViewController refreshAction];
        } else if ([rootViewController isKindOfClass:[MBSeparatedDirectMessageUserViewController class]]) {
            MBSeparatedDirectMessageUserViewController *messageViewController = rootViewController;
            
        } else if ([rootViewController isKindOfClass:[MBMyListViewController class]]) {
            MBMyListViewController *listViewController = rootViewController;
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    MBHomeTimelineViewController *homeViewController = nil;
    id obj = [self.tabBarController.viewControllers firstObject];
    if ([obj isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)obj;
        id objInNavigation = [navigationController.viewControllers firstObject];
        if ([objInNavigation isKindOfClass:[MBHomeTimelineViewController class]]) {
            homeViewController = (MBHomeTimelineViewController *)objInNavigation;
        }
    }
    [[MBTweetManager sharedInstance] deleteAllSavedTweetsOfCurrentAccount];
    [homeViewController saveTimeline];
    
}

#pragma mark -
- (void)popToRootViewControllerForAllTabbedController:(BOOL)animated
{
    for (UINavigationController *navigationController in self.tabBarController.viewControllers) {
        [navigationController popToRootViewControllerAnimated:animated];
    }
}

@end

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
#import "MBMyListTabViewController.h"
#import "MBSearchViewController.h"
#import "MBMyProfileViewController.h"

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
    UITabBarItem *homeBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Timeline", nil) image:homeImage selectedImage:homeSelectedImage];
    homeViewController.tabBarItem = homeBarItem;
    
    MBReplyTimelineViewController *replyTimelineViewController = [[MBReplyTimelineViewController alloc] initWithNibName:@"TimelineTableView" bundle:nil];
    UINavigationController *replyNavigation = [[UINavigationController alloc] initWithRootViewController:replyTimelineViewController];
    [viewControllers addObject:replyNavigation];
    UIImage *replyImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"atMark-Line@2x" ofType:@"png"]];
    UIImage *selectedReplyImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"atMark-Line-Selected@2x" ofType:@"png"]];
    UITabBarItem *replyBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Reply", nil) image:replyImage selectedImage:selectedReplyImage];
    replyTimelineViewController.tabBarItem = replyBarItem;
    
    MBSeparatedDirectMessageUserViewController *separatedDMUserViewController = [[MBSeparatedDirectMessageUserViewController alloc] initWithNibName:@"SeparatedDirectMessagesView" bundle:nil];
    UINavigationController *dmUserNavigation = [[UINavigationController alloc] initWithRootViewController:separatedDMUserViewController];
    [viewControllers addObject:dmUserNavigation];
    UIImage *messageImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Message@2x" ofType:@"png"]];
    UIImage *messageSelectedImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Message-Selected@2x" ofType:@"png"]];
    UITabBarItem *messageBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Message", nil) image:messageImage selectedImage:messageSelectedImage];
    separatedDMUserViewController.tabBarItem = messageBarItem;
    
    MBMyListTabViewController *listViewController = [[MBMyListTabViewController alloc] initWithNibName:@"MBListViewController" bundle:nil];
    UINavigationController *listNavigationController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    [viewControllers addObject:listNavigationController];
    UITabBarItem *listItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"List", nil) image:[UIImage imageNamed:@"List2"] selectedImage:[UIImage imageNamed:@"List-Selected-2"]];
    listViewController.tabBarItem = listItem;
    
    MBMyProfileViewController *myProfileViewController = [[MBMyProfileViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
    UINavigationController *listNavigation = [[UINavigationController alloc] initWithRootViewController:myProfileViewController];
    [viewControllers addObject:listNavigation];
    UIImage *profileImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Profile" ofType:@"png"]];
    UIImage *profileSelectedImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Profile-Selected-Fill" ofType:@"png"]];
    UITabBarItem *listBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"MyProfile", nil) image:profileImage selectedImage:profileSelectedImage];
    myProfileViewController.tabBarItem = listBarItem;
    
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
    
    for (MBAccount *account in [MBAccountManager sharedInstance].accounts) {
        MBTimeLineManager *timelineManager = account.timelineManager;
        if (timelineManager.tweets.count > 0) {
            [[MBTweetManager sharedInstance] deleteAllSavedTweetsForAccount:account];
            [[MBTweetManager sharedInstance] saveTimeline:timelineManager.tweets withAccount:account];
        }
    }
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
            [messageViewController fetchCurrentMessage];
            
        } else if ([rootViewController isKindOfClass:[MBMyListViewController class]]) {
            MBMyListViewController *listViewController = rootViewController;
            [listViewController goBacksLists];
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

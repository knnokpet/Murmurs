//
//  MBSeparatedDirectMessageUserViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSeparatedDirectMessageUserViewController.h"
#import "MBIndividualDirectMessagesViewController.h"

#import "MBImageCacher.h"
#import "MBImageDownloader.h"
#import "MBUserManager.h"
#import "MBDirectMessageManager.h"
#import "MBDirectMessage.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBUser.h"

#import "UIImage+Resize.h"
#import "UIImage+Radius.h"

#import "MBSeparatedDirectMessageUserTableViewCell.h"

@interface MBSeparatedDirectMessageUserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) MBAOuth_TwitterAPICenter *aoAPICenter;
@property (nonatomic, readonly) MBDirectMessageManager *directMessageManager;
@property (nonatomic) NSMutableArray *dataSource;

@end

@implementation MBSeparatedDirectMessageUserViewController

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
    UINib *separatedDMUserCell = [UINib nibWithNibName:@"SeparatedDirectMessageTableViewCell" bundle:nil];
    [self.tableView registerNib:separatedDMUserCell forCellReuseIdentifier:@"SeparatedDMUserCellIdentifier"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    self.aoAPICenter.delegate = self;
    
    [self loadMessages];
    [self receiveChangedAccountNotification];
}

- (void)loadMessages
{
    if ([[MBAccountManager sharedInstance] isSelectedAccount]) {
        [self.aoAPICenter getDeliveredDirectMessagesSinceID:0 maxID:0];
        [self.aoAPICenter getSentDirectMessagesSinceID:0 maxID:0];
    }
}

- (void)receiveChangedAccountNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChangeMyAccount" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSLog(@"user change account to = %@", [[MBAccountManager sharedInstance] currentAccount].screenName);
        _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
        self.aoAPICenter.delegate = self;
        [self.tableView reloadData];
        [self loadMessages];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark TableView Delegate & Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f + 12.0f + 12.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SeparatedDMUserCellIdentifier";
    
    MBSeparatedDirectMessageUserTableViewCell *dmCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [self updateCell:dmCell AtIndexPath:indexPath];
    
    return dmCell;
}

- (void)updateCell:(MBSeparatedDirectMessageUserTableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedMessagesDict = [self.dataSource objectAtIndex:indexPath.row];
    NSString *userKey = [selectedMessagesDict stringForKey:@"user"];
    NSMutableArray *messages = [selectedMessagesDict mutableArrayForKey:@"messages"];
    MBDirectMessage *firstMessage = [messages firstObject];

    MBUser *user = [[MBUserManager sharedInstance] storedUserForKey:userKey];
    
    cell.screenNameLabel.text = user.screenName;
    cell.characterNameLabel.text = user.characterName;
    cell.dateLabel.text = [[[NSDateFormatter alloc] init] stringFromDate:firstMessage.createdDate];
    cell.subtitleLabel.text = firstMessage.tweetText;
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:user.userIDStr];
    cell.iconImageView.image = avatorImage;
    if (!avatorImage) {
        if (NO == user.isDefaultProfileImage) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [MBImageDownloader downloadBigImageWithURL:user.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                    if (image) {
                        [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:user.userIDStr];
                        image = [image imageByScallingToFillSize:CGSizeMake(cell.iconImageView.frame.size.width, cell.iconImageView.frame.size.height)];
                        UIImage *radiusImage = [image imageWithRadius:4.0f];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.iconImageView.image = radiusImage;
                        });
                    }
                }failedHandler:^(NSURLResponse *response, NSError *error){
                    
                }];
            });
        }
    }
}

- (void)updateTableViewDataSource:(NSArray *)messages
{
    if (/*0 == [messages count] ||*/ nil == messages) {
        
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            self.dataSource = [[MBDirectMessageManager sharedInstance] separatedMessages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
}


#pragma mark - Navigation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedMessagesDict = [self.dataSource objectAtIndex:indexPath.row];
    NSString *userKey = [selectedMessagesDict stringForKey:@"user"];
    MBUser *partner = [[MBUserManager sharedInstance] storedUserForKey:userKey];
    NSMutableArray *messages = [[MBDirectMessageManager sharedInstance] separatedMessagesForKey:userKey];
    
    MBIndividualDirectMessagesViewController *individualViewController = [[MBIndividualDirectMessagesViewController alloc] init];
    [individualViewController setPartner:partner];
    [individualViewController setConversation:messages];
    [self.navigationController pushViewController:individualViewController animated:YES];
}

#pragma mark APICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedDirectMessages:(NSArray *)messages
{
    [self updateTableViewDataSource:messages];
}

@end

//
//  MBMessageReceiverViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMessageReceiverViewController.h"

#import "MBUserManager.h"
#import "MBUser.h"
#import "MBUserIDManager.h"
#import "MBImageDownloader.h"
#import "MBImageCacher.h"
#import "MBImageApplyer.h"

#import "MBUsersTableViewCell.h"

static NSString *usersCellIdentifier = @"MBUsersTableViewCellIdentifier";

@interface MBMessageReceiverViewController ()

@end

@implementation MBMessageReceiverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UINib *usersCellNib = [UINib nibWithNibName:@"MBUsersTableViewCell" bundle:nil];
    [self.tableView registerNib:usersCellNib forCellReuseIdentifier:usersCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark TableVIewDelegate Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionsCount = 2;
    if (self.inputedString.length == 0) {
        sectionsCount = 1;
    }
    
    return sectionsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    if (indexPath.section == 0) {
        height = 52;
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (1 == section) {
        return 1;
    }
    
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    
    UITableViewCell *cell;
    
    if (0 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:usersCellIdentifier];
        [self updateCell:(MBUsersTableViewCell *)cell atIndexPath:indexPath];
    } else if (1 == indexPath.section) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [self updateScreenNameCell:cell atIndexpath:indexPath];
    }
    
    
    return cell;
}

- (void)updateCell:(MBUsersTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.dataSource objectAtIndex:indexPath.row];
    MBUser *userAtIndex = [[MBUserManager sharedInstance] storedUserForKey:key];
    cell.characterNameLabel.text = userAtIndex.characterName;
    cell.screenName = userAtIndex.screenName;
    cell.textLabel.textColor = [UIColor blackColor];
    
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:userAtIndex.userIDStr];
    if (!avatorImage) {
        cell.avatorImageView.image = [UIImage imageNamed:@"DefaultImage"];
        if (NO == userAtIndex.isDefaultProfileImage) {
            
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(globalQueue, ^{
                [MBImageDownloader downloadOriginImageWithURL:userAtIndex.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                    if (image) {
                        [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:userAtIndex.userIDStr];
                        CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
                        UIImage *radiusImage = [MBImageApplyer imageForTwitter:image size:imageSize radius:cell.avatorImageView.layer.cornerRadius];
                        [[MBImageCacher sharedInstance] storeTimelineImage:radiusImage forUserID:userAtIndex.userIDStr];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.avatorImageView.image = radiusImage;
                        });
                    }
                    
                }failedHandler:^(NSURLResponse *response, NSError *error){
                    
                }];
                
            });
            
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            CGSize imageSize = CGSizeMake(cell.avatorImageView.frame.size.width, cell.avatorImageView.frame.size.height);
            UIImage *radiusImage = [MBImageApplyer imageForTwitter:avatorImage size:imageSize radius:cell.avatorImageView.layer.cornerRadius];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatorImageView.image = radiusImage;
            });
        });
    }
}

- (void)updateScreenNameCell:(UITableViewCell *)cell atIndexpath:(NSIndexPath *)indexPath
{
    NSString *searchString = NSLocalizedString(@"Search for ", nil);
    NSString *screenNameWithAtmark = [NSString stringWithFormat:@"%@%@", searchString, self.inputedString];
    cell.textLabel.text = screenNameWithAtmark;
    cell.textLabel.textColor = [self.navigationController.navigationBar tintColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        NSString *key = [self.dataSource objectAtIndex:indexPath.row];
        MBUser *userAtIndex = [[MBUserManager sharedInstance] storedUserForKey:key];
        
        if ([_delegate respondsToSelector:@selector(selectReceiverViewController:user:)]) {
            [_delegate selectReceiverViewController:self user:userAtIndex];
        }
    } else if (1 == indexPath.section) {
        if ([_delegate respondsToSelector:@selector(selectSearchReceiverViewController:)]) {
            [_delegate selectSearchReceiverViewController:self];
        }
    }
    
}

#pragma mark ScrollviewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(scrollReceiverViewController:)]) {
        [_delegate scrollReceiverViewController:self];
    }
}

@end

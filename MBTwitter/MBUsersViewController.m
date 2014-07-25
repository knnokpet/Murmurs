//
//  MBUsersViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUsersViewController.h"
#import "MBDetailUserViewController.h"

#import "MBUsersTableViewCell.h"
#import "MBImageDownloader.h"
#import "MBImageApplyer.h"
#import "MBImageCacher.h"

static NSString *usersCellIdentifier = @"UsersCellIdentifier";

@interface MBUsersViewController ()


@end

@implementation MBUsersViewController
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
#pragma mark Setter & Getter
- (void)setUser:(MBUser *)user
{
    _user = user;
}

#pragma mark -
#pragma mark View
- (void)configureModel
{
    
}

- (void)commonConfigureModel
{
    _aoAPICenter = [[MBAOuth_TwitterAPICenter alloc] init];
    _aoAPICenter.delegate = self;
    _users = [NSMutableArray array];
    
    self.enableAdding = NO;
    self.nextCursor = [NSNumber numberWithInt:-1];
    
    [self configureModel];
}

- (void)configureView
{
    UINib *cellNib = [UINib nibWithNibName:@"MBUsersTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:usersCellIdentifier];
}

- (void)commonConfigureView
{
    [self commonConfigureNavigationItem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self configureView];
    
    /* remove nonContent's separator */
    UIView *view = [[UIView alloc] init];
    view.backgroundColor  = [UIColor clearColor];
    [self.tableView setTableHeaderView:view];
    [self.tableView setTableFooterView:view];
    
    // backTimelineIndicator
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    CGFloat bottomMargin = 4.0f;
    CGFloat indicatorHeight = indicatorView.frame.size.height;
    UIView *indicatorContanerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, indicatorHeight + bottomMargin * 2)];
    [indicatorContanerView addSubview:indicatorView];
    indicatorView.center = indicatorContanerView.center;
    self.tableView.tableFooterView = indicatorContanerView;
}

- (void)configureNavigationItem
{
    
}

- (void)commonConfigureNavigationItem
{
    [self configureNavigationItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self commonConfigureModel];
    [self commonConfigureView];
    
    [self goBacksWithCursor:self.nextCursor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;/* for UIScrollView Delegate */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)goBacksWithCursor:(NSNumber *)cursor
{
    long long llCursor = [cursor longLongValue];

    if (0 == llCursor) {
        [self removeBackTimelineIndicatorView];
        return;
    } else {
        self.enableAdding = NO;
        [self backUsersAtCursor:llCursor];
    }
}

- (void)backUsersAtCursor:(long long)cursor
{
    
}

- (void)removeBackTimelineIndicatorView
{
    if ([self.tableView.tableFooterView isKindOfClass:[UIActivityIndicatorView class]]) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = view;
    }
}

#pragma mark -
#pragma mark UITableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBUsersTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:usersCellIdentifier];
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateCell:(MBUsersTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MBUser *userAtIndex = [self.users objectAtIndex:indexPath.row];
    
    cell.characterNameLabel.text = userAtIndex.characterName;
    cell.screenName = userAtIndex.screenName;
    
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

- (NSArray *)decorateAddingArray:(NSArray *)decoratedArray
{
    //overridden
    return decoratedArray;
}

- (void)updateTableViewDataSource:(NSArray *)addingArray
{
    NSArray *decoratedArray = [self decorateAddingArray:addingArray];
    NSInteger addingCount = [decoratedArray count];
    
    if (0 == addingCount) {
        [self removeBackTimelineIndicatorView];
    } else {
        [self decorateAddingArray:decoratedArray];
        [self.users addObjectsFromArray:decoratedArray];
        
        [self.tableView reloadData];
    }
    self.enableAdding = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBUser *selectedUser = [self.users objectAtIndex:indexPath.row];
    MBDetailUserViewController *detailUserViewController = [[MBDetailUserViewController alloc] initWithNibName:@"MBUserDetailView" bundle:nil];
    [detailUserViewController setUser:selectedUser];
    [self.navigationController pushViewController:detailUserViewController animated:YES];
}

#pragma mark ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float max = scrollView.contentInset.top + scrollView.contentInset.bottom + scrollView.contentSize.height - scrollView.bounds.size.height;
    float current = scrollView.contentOffset.y + self.topLayoutGuide.length;
    int intMax = max * 0.5;
    int intCurrent = current;
    if (intMax < intCurrent) {
        if (self.enableAdding) {
            [self goBacksWithCursor:self.nextCursor];
        }
    }
}

#pragma mark -
#pragma mark TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users next:(NSNumber *)next previous:(NSNumber *)previous
{
    self.nextCursor = next;
    self.previousCursor = previous;
    
    [self updateTableViewDataSource:users];
}

@end

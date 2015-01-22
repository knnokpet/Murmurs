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

#import "MBNoResultView.h"
#import "MBErrorView.h"

static NSString *usersCellIdentifier = @"UsersCellIdentifier";

@interface MBUsersViewController ()

@property (nonatomic, readonly) MBNoResultView *resultView;

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
    UIView *indicatorContanerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, indicatorHeight + bottomMargin * 2)];
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
    
    [self goBacksWithCursor:self.nextCursor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self commonConfigureView];
    
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
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
}

- (void)configureNoResultView
{
    if (!self.resultView && self.users.count == 0) {
        _resultView = [[MBNoResultView alloc] initWithFrame:self.view.bounds];
        self.resultView.noResultText = NSLocalizedString(@"No Users...", nil);
        [self.resultView.reloadButton addTarget:self action:@selector(didPushReloadButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:self.resultView aboveSubview:self.tableView];
    }
}

- (void)removeNoResultView
{
    if (!self.resultView.superview) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.resultView.alpha = 0;
    }completion:^(BOOL finished) {
        [self.resultView removeFromSuperview];
        _resultView = nil;
    }];
}

- (void)showErrorViewWithErrorText:(NSString *)errorText
{
    MBErrorView *errorView = [[MBErrorView alloc] initWithErrorText:errorText];
    errorView.center = self.view.center;
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.view addSubview:errorView];
    }completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.5 delay:0.5 options:0 animations:^{
            errorView.alpha = 0.0;
        }completion:^(BOOL finished) {
            [errorView removeFromSuperview];
        }];
    }];
}

#pragma mark Action
- (void)didPushReloadButton
{
    [self goBacksWithCursor:[NSNumber numberWithInt:-1]];
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
    //cell.avatorImageView.userIDStr = userAtIndex.userIDStr;
    //cell.avatorImageView.avatorImage = nil;
    UIImage *avatorImage = [[MBImageCacher sharedInstance] cachedProfileImageForUserID:userAtIndex.userIDStr];
    
    if (!avatorImage) {
        cell.avatorImageView.userIDStr = userAtIndex.userIDStr;
        cell.avatorImageView.avatorImage = nil;
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(globalQueue, ^{
            [MBImageDownloader downloadOriginImageWithURL:userAtIndex.urlHTTPSAtProfileImage completionHandler:^(UIImage *image, NSData *imageData){
                if (image) {
                    [[MBImageCacher sharedInstance] storeProfileImage:image data:imageData forUserID:userAtIndex.userIDStr];
                    UIImage *radiusImage = [self changedSizeRadiusImage:image forUsersCell:cell];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addAvatorImage:radiusImage ForUsersCell:cell forUserIDString:userAtIndex.userIDStr];
                        
                    });
                }
                
            }failedHandler:^(NSURLResponse *response, NSError *error){
                
            }];
            
        });
    } else {
        if (cell.avatorImageView.avatorImage && [cell.avatorImageView.userIDStr isEqualToString:userAtIndex.userIDStr]) {
            return;
        } else {
            cell.avatorImageView.userIDStr = userAtIndex.userIDStr;
            cell.avatorImageView.avatorImage = nil;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *radiusImage = [self changedSizeRadiusImage:avatorImage forUsersCell:cell];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addAvatorImage:radiusImage ForUsersCell:cell forUserIDString:userAtIndex.userIDStr];
                
            });
        });
    }
}

- (UIImage *)changedSizeRadiusImage:(UIImage *)targetedImage forUsersCell:(MBUsersTableViewCell *)cell
{
    CGSize changingSize = cell.avatorImageViewSize;
    UIImage *changedRadiusImage = [MBImageApplyer imageForTwitter:targetedImage size:changingSize radius:cell.avatorImageViewRadius];
    return changedRadiusImage;
}

- (void)addAvatorImage:(UIImage *)image ForUsersCell:(MBUsersTableViewCell *)cell forUserIDString:(NSString *)userIDStr
{
    if (!cell.avatorImageView.avatorImage && [cell.avatorImageView.userIDStr isEqualToString:userIDStr]) {
        [cell addAvatorImage:image];
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
    
    if (addingCount > 0) {
        [self decorateAddingArray:decoratedArray];
        [self.users addObjectsFromArray:decoratedArray];
        
        [self.tableView reloadData];
    } else if (addingCount == 0) {
        [self removeBackTimelineIndicatorView];
    }
    
    if (self.users.count == 0) {
        [self configureNoResultView];
    } else {
        [self removeNoResultView];
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self usersScrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self usersScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self fireFetchingByContentOffsetOfScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self fireFetchingByContentOffsetOfScrollView:scrollView];
    }
    
    [self usersScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)fireFetchingByContentOffsetOfScrollView:(UIScrollView *)scrollView
{
    float max = scrollView.contentInset.top + scrollView.contentInset.bottom + scrollView.contentSize.height - scrollView.bounds.size.height;
    float current = scrollView.contentOffset.y + self.topLayoutGuide.length;
    int intMax = max * 0.5;
    int intCurrent = current;
    if (intMax < intCurrent) {
        if (self.enableAdding && self.users.count != 0) {
            [self goBacksWithCursor:self.nextCursor];
        }
    }
}

#pragma mark
- (void)usersScrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)usersScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)usersScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

#pragma mark -
#pragma mark TwitterAPICenter Delegate
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users next:(NSNumber *)next previous:(NSNumber *)previous
{
    self.nextCursor = next;
    self.previousCursor = previous;
    
    if (self.nextCursor.longLongValue == 0) {
        [self removeBackTimelineIndicatorView];
    }
    
    [self updateTableViewDataSource:users];
}

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center error:(NSError *)error
{
    [self showErrorViewWithErrorText:error.localizedDescription];
    [self configureNoResultView];
}

@end

//
//  MBSearchedTweetViewController.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSearchedTweetViewController.h"

@interface MBSearchedTweetViewController ()

@end

@implementation MBSearchedTweetViewController
#pragma mark -
#pragma mark Inisitialize
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Setter & Getter
- (void)setQuery:(NSString *)query
{
    _query = query;
    
    [self configureTimelineManager]; /* refresh TimelineManager */
    [self configureLoadingView];
    [self.tableView reloadData];
    [self goBackTimelineMaxID:0];
}

#pragma mark -
#pragma mark View
- (void)commonConfigureNavigationItem
{
    // nothing
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance Methods
- (void)goBackTimelineMaxID:(unsigned long long)max
{
    if (self.query.length > 0) {
        [self.aoAPICenter getSearchedTweetsWithQuery:self.query geocode:nil resultLang:@"ja" langOfQuery:@"ja" untilDate:nil maxID:max];
    }
}

- (void)goForwardTimelineSinceID:(unsigned long long)since
{
    if (self.query.length > 0) {
        [self.aoAPICenter getSearchedTweetsWithQuery:self.query geocode:nil resultLang:@"ja" langOfQuery:@"ja" untilDate:nil sinceID:since];
    }
}

- (void)didPushGapButtonSinceID:(unsigned long long)since max:(unsigned long long)max
{
    if (self.query.length > 0) {
        [self.aoAPICenter getSearchedTweetsWithQuery:self.query geocode:nil resultLang:@"ja" langOfQuery:@"ja" untilDate:nil sinceID:since maxID:max];
    }
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

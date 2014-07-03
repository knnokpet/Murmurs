//
//  MBDetailUserInfomationTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailUserInfomationTableViewCell.h"

#import "MBProfileAvatorView.h"
#import "MBProfileDesciptionView.h"
#import "MBProfileInfomationView.h"

#import "MBUser.h"
#import "MBEntity.h"
#import "MBURLLink.h"
#import "MBTweetTextComposer.h"

@implementation MBDetailUserInfomationTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.scrollView.delegate = self;
    //[self updateCellContentsView];
}

- (void)updateCellContentsView
{
    [self configureScrollView];
    [self configureAvatorView];
    [self configureDescriptionView];
    [self configureInformationView];
}

- (void)configureScrollView
{
    NSInteger pageCount = [self numberOfPage];
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = 0;
    
    [self.scrollView setContentSize:CGSizeMake(pageCount * self.bounds.size.width, self.bounds.size.height)];
}

- (void)configureAvatorView
{
    _profileAvatorView = [[MBProfileAvatorView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _profileAvatorView.characterName = self.user.characterName;
    _profileAvatorView.screenName = self.user.screenName;
    _profileAvatorView.backgroundColor = [UIColor darkGrayColor];
    [self.scrollView addSubview:self.profileAvatorView];
}

- (void)configureDescriptionView
{
    if (!self.user) {
        return;
    }
    if (_profileDescriptionView.superview) {
        [_profileDescriptionView removeFromSuperview];
    }
    
    CGRect bounds = self.bounds;
    if (0 < self.user.description.length) {
        CGRect profileFrame = CGRectMake(bounds.size.width, 0, bounds.size.width, bounds.size.height);
        _profileDescriptionView = [[MBProfileDesciptionView alloc] initWithFrame:profileFrame];
        NSAttributedString *descriptionText = [MBTweetTextComposer attributedStringForUser:self.user linkColor:nil];
        [_profileDescriptionView setAttributedString:descriptionText];
        [self.scrollView addSubview:_profileDescriptionView];
        _profileDescriptionView.backgroundColor = [UIColor blackColor];
    }
}

- (void)configureInformationView
{
    if (!self.user) {
        return;
    }
    
    if (_profileInformationView.superview) {
        [_profileInformationView removeFromSuperview];
    }
    
    if (0 < self.user.urlAtProfile.length || 0 < self.user.location.length) {
        CGFloat xOrigin = self.bounds.size.width + self.profileDescriptionView.frame.size.width;
        _profileInformationView = [[MBProfileInfomationView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.bounds.size.width, self.bounds.size.height)];
        [self.profileInformationView setLocationText:self.user.location];
        MBURLLink *urlInProfile = self.user.entity.urls.firstObject;
        [self.profileInformationView setUrlText:urlInProfile.displayText];
        [self.scrollView addSubview:self.profileInformationView];
        _profileInformationView.backgroundColor = [UIColor blackColor];
    }
    
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

#pragma mark - Setter & Getter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(MBUser *)user
{
    _user = user;
}

#pragma mark -
#pragma mark Instance Methods
- (NSInteger)numberOfPage
{
    NSInteger pageCount = 1;
    if (0 < self.user.description.length && (0 < self.user.urlAtProfile.length || 0 < self.user.location.length)) {
        pageCount = 3;
    } else if (0 < self.user.description.length || self.user.urlAtProfile.length || 0 < self.user.location.length) {
        pageCount = 2;
    }
    
    return pageCount;
}

#pragma mark Action
- (void)pageControl:(id)sender
{
    CGRect frame = self.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark -
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView == scrollView) {
        CGFloat viewWidth = self.bounds.size.width;
        self.pageControl.currentPage = (self.scrollView.contentOffset.x + 1) / viewWidth;
    }
}

@end

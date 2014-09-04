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
    self.backgroundColor = [UIColor darkGrayColor];
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
    if (_profileAvatorView.superview) {
        [_profileAvatorView removeFromSuperview];
    }
    
    _profileAvatorView = [[MBProfileAvatorView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _profileAvatorView.characterName = self.user.characterName;
    _profileAvatorView.screenName = self.user.screenName;
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
    if (0 < self.user.desctiprion.length) {
        CGRect profileFrame = CGRectMake(bounds.size.width, 0, bounds.size.width, bounds.size.height);
        _profileDescriptionView = [[MBProfileDesciptionView alloc] initWithFrame:profileFrame];
        NSAttributedString *descriptionText = [MBTweetTextComposer attributedStringForUser:self.user linkColor:nil];
        [_profileDescriptionView setAttributedString:descriptionText];
        [self.scrollView addSubview:_profileDescriptionView];
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
    if (0 < self.user.desctiprion.length && (0 < self.user.urlAtProfile.length || 0 < self.user.location.length)) {
        pageCount = 3;
    } else if (0 < self.user.desctiprion.length || self.user.urlAtProfile.length || 0 < self.user.location.length) {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        CGFloat viewWidth = self.bounds.size.width;
        
        CGFloat alpha = scrollView.contentOffset.x / viewWidth;
        if (alpha > 0.5) {
            alpha = 0.5;
        }
        UIColor *tlancerucentBlack = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
        self.scrollView.backgroundColor = tlancerucentBlack;
    }
}

@end

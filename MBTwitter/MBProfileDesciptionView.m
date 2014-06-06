//
//  MBProfileDesciptionView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBProfileDesciptionView.h"

#import "MBTweetTextView.h"

@implementation MBProfileDesciptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureView:frame];
    }
    return self;
}

- (void)configureView:(CGRect)frame
{
    self.descriptionTextView = [[MBTweetTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
    [self addSubview:self.descriptionTextView];
    self.locationTextView = [[MBTweetTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
    [self addSubview:self.locationTextView];
    self.urlTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
    [self addSubview:self.urlTextView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

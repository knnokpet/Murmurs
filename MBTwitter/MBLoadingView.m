//
//  MBLoadingView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLoadingView.h"

@implementation MBLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.activityIndicatorView];
        CGPoint center = self.center;
        center.y -= self.activityIndicatorView.frame.size.height;
        self.activityIndicatorView.center = self.center;
        [self.activityIndicatorView startAnimating];
    }
    return self;
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

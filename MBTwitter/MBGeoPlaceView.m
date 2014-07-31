//
//  MBGeoPlaceView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBGeoPlaceView.h"

@implementation MBGeoPlaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        _displayText = text;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(0.0f, 0.2f);
    gradientLayer.endPoint = CGPointMake(0.0f, 0.0f);
    self.layer.mask = gradientLayer;
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

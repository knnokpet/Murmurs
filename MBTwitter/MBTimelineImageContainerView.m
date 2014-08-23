//
//  MBTimelineImageContainerView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineImageContainerView.h"

@implementation MBTimelineImageContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImageCount:(NSInteger)imageCount
{
    _imageCount = imageCount;
    [self configureImageView];
}

- (void)setImages:(NSArray *)images
{
    _images = images;
}

- (void)configureImageView
{
    CGSize boundsSize = self.bounds.size;
    MBMediaImageView *imageView = [[MBMediaImageView alloc] initWithFrame:CGRectMake(0, 0, boundsSize.width, boundsSize.height)];
    imageView.image = [UIImage imageNamed:@"TimelineMediaImageDefault"];
    [self addSubview:imageView];
    
    _imageViews = @[imageView];
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

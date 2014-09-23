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
    if (_imageCount != imageCount) {
        _imageCount = imageCount;
        [self configureImageView];
    }
}

- (void)setImages:(NSArray *)images
{
    _images = images;
}

- (void)configureImageView
{
    CGSize boundsSize = self.bounds.size;
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.imageCount];
    for (int i = 0; i < self.imageCount; i ++) {
        MBMediaImageView *imageView = [[MBMediaImageView alloc] initWithFrame:CGRectZero];
        [images addObject:imageView];
    }

    CGRect frame = CGRectMake(0, 0, boundsSize.width, boundsSize.height);
    MBMediaImageView *imageView = [images firstObject];
    imageView.frame = frame;
    
    [self addSubview:imageView];
    
    _imageViews =images;
}

- (void)resetImageOfMediaImageView
{
    for (MBMediaImageView *mediaImageView in self.imageViews) {
        mediaImageView.mediaImage = nil;
    }
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

//
//  MBTimelineImageContainerView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBTimelineImageContainerView : UIView

@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) NSArray *imageViews;

- (void)setImageCount:(NSInteger)imageCount;
- (void)setImages:(NSArray *)images;

@end

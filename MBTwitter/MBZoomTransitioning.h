//
//  MBZoomTransitioning.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBZoomTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, readonly, assign) BOOL isReverse;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, readonly) CGPoint animationPoint;
@property (nonatomic, readonly) CGAffineTransform transformScale;

- (instancetype)initWithPoint:(CGPoint)point;
- (void)setIsReverse:(BOOL)isReverse;
- (void)setTransformScale:(CGAffineTransform)transformScale;

@end

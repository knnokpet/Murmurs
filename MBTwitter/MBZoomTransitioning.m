//
//  MBZoomTransitioning.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBZoomTransitioning.h"

static const NSTimeInterval MBZoomTransitioningDuration = 0.3f;

@implementation MBZoomTransitioning

- (instancetype)initWithPoint:(CGPoint)point
{
    self = [super init];
    if (self) {
        _duration = MBZoomTransitioningDuration;
        _animationPoint = point;
        [self commonInitialize];
    }
    
    return self;
}

- (void)commonInitialize
{
    _isReverse = NO;
    _transformScale = CGAffineTransformMakeScale(0.01, 0.01);
}

- (void)setIsReverse:(BOOL)isReverse
{
    _isReverse = isReverse;
}

- (void)setAnimationPoint:(CGPoint)animationPoint
{
    _animationPoint = animationPoint;
}

- (void)setTransformScale:(CGAffineTransform)transformScale
{
    _transformScale = transformScale;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (self.isReverse) {
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    } else {
        toViewController.view.transform = self.transformScale;
        [containerView addSubview:toViewController.view];
        CGRect toRect = toViewController.view.frame;
        toRect.origin = self.animationPoint;
        toViewController.view.frame = toRect;
    }
    
    [UIView animateKeyframesWithDuration:self.duration delay:0 options:0 animations:^{
        if (self.isReverse) {
            fromViewController.view.transform = self.transformScale;
            CGRect fromRect = fromViewController.view.frame;
            fromRect.origin = self.animationPoint;
            fromViewController.view.frame = fromRect;
            
            
        } else {
            toViewController.view.transform = CGAffineTransformIdentity;
            CGRect toRect = toViewController.view.frame;
            toRect.origin = fromViewController.view.frame.origin;
            toViewController.view.frame = toRect;
            
        }
        
    }completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

@end

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
    }
    
    return self;
}

- (void)setIsReverse:(BOOL)isReverse
{
    _isReverse = isReverse;
}

- (void)setAnimationPoint:(CGPoint)animationPoint
{
    _animationPoint = animationPoint;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (self.isReverse) {
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    } else {
        toViewController.view.transform = CGAffineTransformMakeScale(0, 0);
        [containerView addSubview:toViewController.view];
        toViewController.view.center = self.animationPoint;
    }
    
    [UIView animateKeyframesWithDuration:self.duration delay:0 options:0 animations:^{
        if (self.isReverse) {
            fromViewController.view.transform = CGAffineTransformMakeScale(0, 0);
            fromViewController.view.center = self.animationPoint;
        } else {
            toViewController.view.transform = CGAffineTransformIdentity;
            toViewController.view.center = fromViewController.view.center;
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

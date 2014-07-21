//
//  UIImage+Radius.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "UIImage+Radius.h"

@implementation UIImage (Radius)

- (UIImage *)imageWithRadius:(CGFloat)radius
{
    if (radius == 0.0f) {
        return self;
    }
    
    CALayer *layser = [CALayer layer];
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    layser.frame = CGRectMake(0, 0, size.width, size.height);
    layser.contents = (id)self.CGImage;
    layser.masksToBounds = YES;
    layser.cornerRadius = radius;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [layser renderInContext:context];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return roundedImage;
}

@end

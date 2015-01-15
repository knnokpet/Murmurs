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
    
    CALayer *layer = [CALayer layer];
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    layer.frame = CGRectMake(0, 0, size.width, size.height);
    layer.contents = (id)self.CGImage;
    layer.masksToBounds = YES;
    layer.cornerRadius = radius;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [layer renderInContext:context];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

@end

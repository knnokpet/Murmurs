//
//  UIImage+Resize.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)imageForResizing:(UIImage *)image ToSize:(CGSize)size
{
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

/* 以下 unused */
- (UIImage *)imageByScallingToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode
{
    if (contentMode == UIViewContentModeScaleToFill) {
        return [self imageByScallingToFillSize:size];
    } else if (contentMode == UIViewContentModeScaleAspectFill || UIViewContentModeScaleAspectFit) {
        CGFloat horizontalRatio = self.size.width / size.width;
        CGFloat verticalRatio = self.size.height / size.height;
        CGFloat ratio;
        
        if (contentMode == UIViewContentModeScaleAspectFit) {
            ratio = MAX(horizontalRatio, verticalRatio);
        } else {
            ratio = MIN(horizontalRatio, verticalRatio);
        }
        
        CGSize sizeForAspectScale = CGSizeMake(self.size.width / ratio, self.size.height / ratio);
        
        UIImage *image = [self imageByScallingToFillSize:sizeForAspectScale];
        
        if (contentMode == UIViewContentModeScaleAspectFill) {
            CGRect subRect = CGRectMake(floor((sizeForAspectScale.width - size.width) / 2), floor((sizeForAspectScale.height - size.height) / 2), size.width, size.height);
            image = [image imageByCroppingToBounds:subRect];
        }
        
        return image;
    }
    
    return nil;
}

- (UIImage *)imageByCroppingToBounds:(CGRect)bounds
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (UIImage *)imageByScallingToFillSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageByScallingAspectFillSize:(CGSize)size
{
    return [self imageByScallingToSize:size contentMode:UIViewContentModeScaleAspectFill];
}

- (UIImage *)imageByScallingAspectFitSize:(CGSize)size
{
    return [self imageByScallingToSize:size contentMode:UIViewContentModeScaleAspectFit];
}

@end

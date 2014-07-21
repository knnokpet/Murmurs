//
//  UIImage+MaskColor.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/18.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "UIImage+MaskColor.h"

@implementation UIImage (MaskColor)

- (UIImage *)imageWithMaskColor:(UIColor *)color
{
    CGImageRef maskImageRef = self.CGImage;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpaceRef, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    CGContextClipToMask(bitmapContext, bounds, maskImageRef);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *coloredImage = [UIImage imageWithCGImage:cgImage];
    
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(cgImage);
    
    return coloredImage;
}

@end

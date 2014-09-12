//
//  UIImage+Crop.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "UIImage+Crop.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage (Crop)

+ (UIImage *)centerCroppingImageWithImage:(UIImage *)image atSize:(CGSize)size
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);

    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize croppingSize = CGSizeMake(size.width * screenScale, size.height * screenScale);
    if (imageSize.width < croppingSize.width || imageSize.height < croppingSize.height) {
        croppingSize = size;
    }
    
    CGPoint center = CGPointMake(imageSize.width / 2.f, imageSize.height / 2.f);
    CIImage *centerCroppedImage = [ciImage imageByCroppingToRect:CGRectMake(center.x - croppingSize.width / 2.f, center.y - croppingSize.height / 2.f, croppingSize.width, croppingSize.height)];
    UIImage *croppedImage = [[UIImage alloc] initWithCIImage:centerCroppedImage scale:screenScale orientation:UIImageOrientationUp];
    
    return croppedImage;
}

+ (CGAffineTransform)scaleOfCroppingWithImage:(UIImage *)image bySize:(CGSize)size
{
    if (!image) {
        return CGAffineTransformIdentity;
    }
    
    CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize croppingSize = CGSizeMake(size.width * screenScale, size.height * screenScale);
    CGAffineTransform scale = CGAffineTransformMakeScale(croppingSize.width / imageSize.width, croppingSize.height / imageSize.height);
    return scale;
}

@end

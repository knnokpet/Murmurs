//
//  MBImageApplyer.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBImageApplyer.h"

@implementation MBImageApplyer
/* unused */
+ (UIImage *)imageForTwitter:(UIImage *)image byScallingToFillSize:(CGSize)size radius:(CGFloat)radius
{
    MBImageApplyer *applyer = [[MBImageApplyer alloc] init];
    return [applyer imageForTwitter:image byScallingToFillSize:size radius:radius];
}

/* unused */
+ (UIImage *)imageForTwitter:(UIImage *)image byScallingAspectFillSize:(CGSize)size radius:(CGFloat)radius
{
    MBImageApplyer *applyer = [[MBImageApplyer alloc] init];
    return [applyer imageForTwitter:image byScallingAspectFillSize:size radius:radius];
}

+ (UIImage *)imageForTwitter:(UIImage *)image size:(CGSize)size radius:(CGFloat)radius
{
    UIImage *resizedImage = [image imageForResizing:image ToSize:size];
    UIImage *radiusImage = [resizedImage imageWithRadius:radius];
    return radiusImage;
}

+ (UIImage *)imageForMediaWithImage:(UIImage *)image size:(CGSize)size
{
    UIImage *centerCroppedImage = [UIImage centerCroppingImageWithImage:image atSize:size];
    return centerCroppedImage;
}

/* unused */
- (UIImage *)imageForTwitter:(UIImage *)image byScallingToFillSize:(CGSize)size radius:(CGFloat)radius
{
    UIImage *resizedImage = [image imageByScallingToFillSize:size];
    UIImage *radiusImage = [resizedImage imageWithRadius:radius];
    return radiusImage;
}

/* unused */
- (UIImage *)imageForTwitter:(UIImage *)image byScallingAspectFillSize:(CGSize)size radius:(CGFloat)radius
{
    UIImage *resizedImage = [image imageByScallingAspectFillSize:size];
    UIImage *radiusImage = [resizedImage imageWithRadius:radius];
    return radiusImage;
}

@end

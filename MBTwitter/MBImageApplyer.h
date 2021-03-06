//
//  MBImageApplyer.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIImage+Resize.h"
#import "UIImage+Radius.h"
#import "UIImage+Crop.h"

@interface MBImageApplyer : NSObject
/* unused */
+ (UIImage *)imageForTwitter:(UIImage *)image byScallingToFillSize:(CGSize)size radius:(CGFloat)radius;
/* unused */
+ (UIImage *)imageForTwitter:(UIImage *)image byScallingAspectFillSize:(CGSize)size radius:(CGFloat)radius;


+ (UIImage *)imageForTwitter:(UIImage *)image size:(CGSize)size radius:(CGFloat)radius;
+ (UIImage *)imageForMediaWithImage:(UIImage *)image size:(CGSize)size;

@end

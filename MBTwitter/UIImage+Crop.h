//
//  UIImage+Crop.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

+ (UIImage *)centerCroppingImageWithImage:(UIImage *)image atSize:(CGSize)size;

/* unused */
+ (CGAffineTransform)scaleOfCroppingWithImage:(UIImage *)image bySize:(CGSize)size;

@end

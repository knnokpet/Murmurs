//
//  UIImage+Resize.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)imageByScallingToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;
- (UIImage *)imageByCroppingToBounds:(CGRect)bounds;
- (UIImage *)imageByScallingToFillSize:(CGSize)size;
- (UIImage *)imageByScallingAspectFillSize:(CGSize)size;
- (UIImage *)imageByScallingAspectFitSize:(CGSize)size;

@end

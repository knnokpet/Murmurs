//
//  MBLabelImageHeaderView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/19.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBLabelImageHeaderView : UIView

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSString *labelString;

- (void)setImage:(UIImage *)image;
- (void)setLabelString:(NSString *)labelString;

@end

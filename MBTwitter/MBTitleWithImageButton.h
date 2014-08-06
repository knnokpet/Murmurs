//
//  MBTitleWithImageButton.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBTitleWithImageButton : UIButton

@property (nonatomic, readonly) UIImage *buttonImage;
@property (nonatomic, readonly) NSString *buttonTitle;
- (void)setButtonImage:(UIImage *)buttonImage;
- (void)setButtonTitle:(NSString *)buttonTitle;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image;
@end

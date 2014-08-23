//
//  MBBlurView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"

@interface MBBlurView : UIView

@property (nonatomic, weak) UIView *backgroundView;

- (void)updateBlurView;

@end

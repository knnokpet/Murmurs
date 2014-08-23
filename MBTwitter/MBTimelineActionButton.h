//
//  MBTimelineActionButton.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBTimelineActionButton : UIButton

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *image;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

@end

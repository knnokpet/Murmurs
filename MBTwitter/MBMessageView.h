//
//  MBMessageView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBMessageView : UIView

@property (nonatomic, assign, readonly) BOOL popsFromRight;
- (void)setPopsFromRight:(BOOL)popsFromRight;

@end

//
//  MBNavigationControllerTitleView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBNavigationControllerTitleView : UIView

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *screenName;
- (void)setTitle:(NSString *)title;
- (void)setScreenName:(NSString *)screenName;

@end

//
//  MBNoResultView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/15.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBNoResultView : UIView

@property (nonatomic, readonly) UIButton *reloadButton;

@property (nonatomic, readonly) NSString *noResultText;
@property (nonatomic, readonly, assign) BOOL isReloading;
@property (nonatomic, readonly, assign) BOOL requireReloadButton;
- (void)setNoResultText:(NSString *)noResultText;
- (void)setIsReloading:(BOOL)isReloading withAnimated:(BOOL)animated;
- (void)setRequireReloadButton:(BOOL)requireReloadButton;

@end

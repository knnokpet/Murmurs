//
//  MBProfileAvatorView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBAvatorImageView;
@class MBShadowBlurLabel;
@interface MBProfileAvatorView : UIView

@property (nonatomic) MBAvatorImageView *avatorImageView;
@property (nonatomic) MBShadowBlurLabel *characterNameLabel;
@property (nonatomic) MBShadowBlurLabel *screenNameLabel;
@property (nonatomic) UIImageView *protectImageView;
@property (nonatomic) UIImageView *verifiedIconImageView;

@property (nonatomic) NSString *characterName;
@property (nonatomic) NSString *screenName;
@property (nonatomic, assign) BOOL isProtected;
@property (nonatomic, assign) BOOL isVerified;
- (void)setCharacterName:(NSString *)characterName;
- (void)setScreenName:(NSString *)screenName;
- (void)setIsProtected:(BOOL)isProtected;
- (void)setIsVerified:(BOOL)isVerified;

- (void)addAvatorImage:(UIImage *)image animated:(BOOL)animated;

@end

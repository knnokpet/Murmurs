//
//  MBProfileAvatorView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBAvatorImageView;
@interface MBProfileAvatorView : UIView

@property (nonatomic) MBAvatorImageView *avatorImageView;
@property (nonatomic) UILabel *characterNameLabel;
@property (nonatomic) UILabel *screenNameLabel;

@property (nonatomic) NSString *characterName;
@property (nonatomic) NSString *screenName;
- (void)setCharacterName:(NSString *)characterName;
- (void)setScreenName:(NSString *)screenName;

@end

//
//  MBCharacterScreenNameView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBCharacterScreenNameView : UIView

@property (nonatomic, readonly) NSAttributedString *characterScreenString;
- (void)setCharacterScreenString:(NSAttributedString *)characterScreenString;

@end

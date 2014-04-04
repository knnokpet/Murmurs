//
//  MBTweetTextView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBTweetTextView : UIView

@property (nonatomic, readonly) NSAttributedString *attributedString;

+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString
                         constraintSize:(CGSize)constraintSize;
+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString
                         constraintSize:(CGSize)constraintSize
                              lineSpace:(CGFloat)lineSpace;
+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString
                         constraintSize:(CGSize)constraintSize
                              lineSpace:(CGFloat)lineSpace
                                   font:(UIFont *)font;
+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString
                         constraintSize:(CGSize)constraintSize
                              lineSpace:(CGFloat)lineSpace
                         paragraghSpace:(CGFloat)paragraghSpace
                                   font:(UIFont *)font;

- (void)setAttributedString:(NSAttributedString *)attributedString;
@end

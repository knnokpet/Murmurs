//
//  MBTweetTextView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBLinkText.h"

@protocol MBTweetTextViewDelegate;
@interface MBTweetTextView : UIView

@property (weak, nonatomic) id <MBTweetTextViewDelegate> delegate;

@property (nonatomic, readonly) NSAttributedString *attributedString;
@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *highlightedTextColor;
@property (nonatomic) CGFloat lineSpace;
@property (nonatomic) CGFloat paragraphSpace;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) NSTextAlignment alignment;
@property (nonatomic) NSLineBreakMode lineBreakMode;

@property (nonatomic) UIColor *selectedTextBackgroundColor;
@property (nonatomic) UIColor *linkHighlightColor;

@property (nonatomic, assign, readonly) BOOL isSelectable;


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
+ (CGRect)rectForLongestDrawingTextWithAttributedString:(NSAttributedString *)attributedString
                                         constraintSize:(CGSize)constraintSize
                                              lineSpace:(CGFloat)lineSpace
                                         paragraghSpace:(CGFloat)paragraghSpace
                                                   font:(UIFont *)font;

- (void)setAttributedString:(NSAttributedString *)attributedString;
- (void)setIsSelectable:(BOOL)isSelectable;
- (MBLinkText *)linkAtPoint:(CGPoint)point; // longPress 時にリンクが押されているかどうかを確認するために public メソッドに変更。
@end


@protocol MBTweetTextViewDelegate <NSObject>

@optional
/* unused
- (void)tweetTextView:(MBTweetTextView *)textView clickOnLink:(MBLinkText *)linktext;
 */
- (void)tweetTextView:(MBTweetTextView *)textView clickOnLink:(MBLinkText *)linktext point:(CGPoint)touchePoint;
- (void)tweetTextViewShowMagnifier:(MBTweetTextView *)textView point:(CGPoint)point;
- (void)tweetTextViewHideMagnifier:(MBTweetTextView *)textView;
- (void)tweetTextViewShowMagnifierRange:(MBTweetTextView *)textView point:(CGPoint)point;
- (void)tweetTextViewHideMagnifierRange:(MBTweetTextView *)textView;

@end

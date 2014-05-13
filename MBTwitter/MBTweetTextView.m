//
//  MBTweetTextView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetTextView.h"
#import "MBTextLayout.h"
#import "MBLineLayout.h"
#import "MBLinkText.h"

@interface MBTweetTextView()

@property (nonatomic, readonly) MBTextLayout *textLayout;

@end

@implementation MBTweetTextView

#pragma mark -
#pragma mark Initialize
- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    _textLayout = [[MBTextLayout alloc] init];
    _textLayout.bound = self.bounds;
}

#pragma mark -
#pragma mark DrawingFrame
+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize
{
    return [self frameRectWithAttributedString:attributedString constraintSize:constraintSize lineSpace:0.0f];
}

+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize lineSpace:(CGFloat)lineSpace
{
    return [self frameRectWithAttributedString:attributedString constraintSize:constraintSize lineSpace:lineSpace font:nil];
}

+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize lineSpace:(CGFloat)lineSpace font:(UIFont *)font
{
    return [self frameRectWithAttributedString:attributedString constraintSize:constraintSize lineSpace:lineSpace paragraghSpace:0.0f font:font];
}

+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize lineSpace:(CGFloat)lineSpace paragraghSpace:(CGFloat)paragraghSpace font:(UIFont *)font
{
    NSInteger length = attributedString.length;
    NSRange textRange = NSMakeRange(0, length);
    NSMutableAttributedString *mutableAttributedString = attributedString.mutableCopy;
    
    CTTextAlignment textAlignment = kCTTextAlignmentNatural;
    CGFloat lineSpacing = roundf(lineSpace);
    CGFloat lineHeight = 0.0f;
    CGFloat paragraphSpacing = roundf(paragraghSpace);
    
    CTParagraphStyleSetting setting[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(lineHeight), &lineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(lineHeight), &lineHeight},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(paragraphSpacing), &paragraphSpacing},
    };
    
    CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(setting, sizeof(setting) / sizeof(CTParagraphStyleSetting));
    [mutableAttributedString addAttributes:@{(id)kCTParagraphStyleAttributeName: (__bridge id) paragraphStyleRef} range:textRange];
    CFRelease(paragraphStyleRef);
    
    attributedString = mutableAttributedString;
    
    if (font) {
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFloat fontSize = font.pointSize;
        CTFontRef fontRef = CTFontCreateWithName(fontName, fontSize, NULL);
        [mutableAttributedString addAttributes:@{(id)kCTFontAttributeName: (__bridge id)fontRef} range:textRange];
        CFRelease(fontRef);
        attributedString = mutableAttributedString;
    }
    
    return [MBTextLayout frameRectWithAttributedString:attributedString constraintSize:constraintSize];
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setAttributedString:(NSAttributedString *)attributedString
{
    _attributedString = attributedString.copy;
    
    [self setNeedsDisplayInRect:self.bounds];
}

#pragma mark -
- (void)setLayoutAttributes
{
    [self setFontAttribute];
    [self setTextColorAttribute];
    [self setParagraphStyleAttribute];
}

- (void)setFontAttribute
{
    if (!self.font) {
        return;
    }
    
    CFStringRef fontName = (__bridge CFStringRef)self.font.fontName;
    CGFloat fontSize = self.font.pointSize;
    CTFontRef fontRef = CTFontCreateWithName(fontName, fontSize, NULL);
    [self setAttributes:@{(id)kCTFontAttributeName: (__bridge id)fontRef}];
    CFRelease(fontRef);
}

- (void)setTextColorAttribute
{
    if (!self.textColor) {
        return;
    }
    
    CGColorRef colorRef = self.textColor.CGColor;
    [self setAttributes:@{(id)kCTForegroundColorAttributeName: (__bridge id)colorRef}];
    CFRelease(colorRef);
}

- (void)setParagraphStyleAttribute
{
    CTTextAlignment alignment = (CTTextAlignment)self.alignment;
    CTLineBreakMode lineBreakMode = (CTLineBreakMode)self.lineBreakMode;
    CGFloat lineSpacing = roundf(self.lineSpace);
    CGFloat paragraphSpacing = roundf(self.paragraphSpace);
    CGFloat lineHeight = roundf(self.lineHeight);
    
    CTParagraphStyleSetting setting[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(paragraphSpacing), &paragraphSpacing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(lineHeight), &lineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(lineHeight), &lineHeight},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode},
    };
    CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(setting, sizeof(setting) / sizeof(CTParagraphStyleSetting));
    [self setAttributes:@{(id)kCTParagraphStyleAttributeName: (__bridge id)paragraphStyleRef}];
    CFRelease(paragraphStyleRef);
}


- (void)setAttributes:(NSDictionary *)attributes
{
    NSInteger length = self.attributedString.length;
    NSMutableAttributedString *mutableAttributedString = self.attributedString.mutableCopy;
    if (attributes) {
        [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, length)];
    }
    
    self.attributedString = mutableAttributedString;
}

- (MBLinkText *)linkAtPoint:(CGPoint)point
{
    for (MBLineLayout *lineLayout in self.textLayout.lineLayouts) {
        MBLinkText *linkText = [lineLayout linkAtPoint:point];
        if (nil != linkText) {
            return linkText;
        }
    }
    
    return nil;
}

#pragma mark -
- (void)updateLayout
{
    [self setLayoutAttributes];
    
    self.textLayout.attributedString = self.attributedString;
    self.textLayout.bound = self.bounds;
    
    [self.textLayout update];
}

#pragma mark -
#pragma mark Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // setting
    [self updateLayout];
    
    // draw
    [self.textLayout drawInContext:context];
}

#pragma mark -
#pragma mark touch
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    MBLinkText *linkText = [self linkAtPoint:point];
    if (nil != linkText) {
        return [super hitTest:point withEvent:event];
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end

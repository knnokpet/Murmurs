//
//  MBTweetTextView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetTextView.h"
#import "MBTextLayout.h"

@interface MBTweetTextView()

@property (nonatomic, readonly) MBTextLayout *textLayout;

@end

@implementation MBTweetTextView

#pragma mark -
#pragma mark Initialize
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initialize
{
    _textLayout = [[MBTextLayout alloc] init];
}

#pragma mark -
#pragma mark DrawingFrame
+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize lineSpace:(CGFloat)lineSpace paragraghSpace:(CGFloat)paragraghSpace font:(UIFont *)font
{
    NSInteger length = attributedString.length;
    NSRange textRange = NSMakeRange(0, length);
    NSMutableAttributedString *mutableAttributedString = attributedString.mutableCopy;
    
    NSMutableParagraphStyle *paragraghStyle = [[NSMutableParagraphStyle alloc] init];
    paragraghStyle.alignment = NSTextAlignmentNatural;
    paragraghStyle.lineSpacing = lineSpace;
    paragraghStyle.paragraphSpacing = paragraghSpace;
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraghStyle range:textRange];
    
    if (font) {
        [mutableAttributedString addAttribute:NSFontAttributeName value:font range:textRange];
    }
    attributedString = mutableAttributedString;
    
    return [MBTextLayout frameRectWithAttributedString:attributedString constraintSize:constraintSize];
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setAttributedString:(NSAttributedString *)attributedString
{
    _attributedString = attributedString;
    
    [self setNeedsDisplayInRect:self.bounds];
}

#pragma mark -

#pragma mark -
#pragma mark Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end

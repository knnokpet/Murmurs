//
//  MBTextLayout.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@class MBTextSelection;
@interface MBTextLayout : NSObject

@property (nonatomic) NSAttributedString *attributedString;
@property (nonatomic, readonly) NSArray *lineLayouts;
@property (nonatomic, readonly) NSArray *links;
@property (nonatomic) MBTextSelection *textSelection;

@property (nonatomic) CTTextAlignment textAlignment;
@property (nonatomic) CTLineBreakMode lineBreakMode;

@property (nonatomic) CGRect bound;
@property (nonatomic, readonly) CGRect frameRect;

+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize;
+ (CGRect)rectForLongestDrawingWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize;

- (id)initWithAttributedString:(NSAttributedString *)attributedString;
- (void)update;
- (void)drawInContext:(CGContextRef)context;

- (CFIndex)stringIndexForPosition:(CGPoint)point;
- (CFIndex)stringIndexForClosePosition:(CGPoint)point;
- (CGRect)rectOfStringForIndex:(CFIndex)index;

- (void)setSelectionStartWithPoint:(CGPoint)point;
- (void)setSelectionEndWithPoint:(CGPoint)point;
- (void)setSelectionEndWithClosePoint:(CGPoint)point;
- (void)setSelectionStartWithFirstPoint:(CGPoint)point;

- (void)setSelectionWithPoint:(CGPoint)point;

@end

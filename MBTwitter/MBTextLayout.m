//
//  MBTextLayout.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTextLayout.h"
#import "MBLineLayout.h"
#import "MBLinkText.h"
#import "MBTextGeo.h"
#import "MBTextSelection.h"

@interface MBTextLayout()
{
    CTFramesetterRef framesetterRef;
    CTFrameRef frameRef;
}

@end

@implementation MBTextLayout

#pragma mark -
#pragma mark
- (id)initWithAttributedString:(NSAttributedString *)attributedString
{
    self = [super init];
    if (self) {
        self.attributedString = attributedString.copy;
    }
    
    return self;
}

- (void)dealloc
{
    if (framesetterRef) {
        CFRelease(framesetterRef);
    }
    
    if (frameRef) {
        CFRelease(frameRef);
    }
}

#pragma mark -
#pragma mark Frame
+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize
{
    MBTextLayout *textLayout = [[MBTextLayout alloc] initWithAttributedString:attributedString];
    CGRect bound = CGRectZero;
    bound.size = constraintSize;
    textLayout.bound = bound;
    
    
    [textLayout createFramesetter];
    [textLayout createFrame];
    
    CGRect textLayoutFrame = textLayout.frameRect;
    
    return textLayoutFrame;
}

#pragma mark -
- (void)createFramesetter
{
    if (framesetterRef) {
        CFRelease(framesetterRef);
    }
    
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)self.attributedString;
    if (attributedStringRef) {
        framesetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
    } else {
        attributedStringRef = CFAttributedStringCreate(NULL, CFSTR(""), NULL);
        framesetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
        CFRelease(attributedStringRef);
    }
}

- (void)createFrame
{
    if (frameRef) {
        CFRelease(frameRef);
    }
    
    CGRect frameRect = self.bound;
    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, [_attributedString length]), NULL, CGSizeMake(frameRect.size.width, CGFLOAT_MAX), NULL);
    
    frameRect.origin.y = CGRectGetMaxY(frameRect) - textSize.height;
    frameRect.size.height = textSize.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, frameRect);
    frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    
    
    _frameRect = frameRect;
    _frameRect.origin.y = 0.0f;
}

- (void)createLink
{
    NSMutableArray *links = [NSMutableArray array];
    
    NSUInteger length = [self.attributedString length];
    [self.attributedString enumerateAttribute:NSLinkAttributeName inRange:NSMakeRange(0, length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            NSString *text = [self.attributedString.string substringWithRange:range];
            MBLinkText *linkText = [[MBLinkText alloc] initWithText:text object:value range:range];
            [links addObject:linkText];
        }
    }];
    
    _links = links;
}

- (void)createLine
{
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    NSMutableArray *lineLayouts = [NSMutableArray arrayWithCapacity:lineCount];
    NSInteger index = 0;
    for (; index < lineCount; index ++) {
        CGPoint lineOrigin = lineOrigins[index];
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, index);
        
        CGFloat ascent, descent, leading;
        CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        MBLineMetrics metrics;
        metrics.ascent = ascent;
        metrics.descent = descent;
        metrics.leading = leading;
        metrics.width = width;
        metrics.trailingWhiteSpaceWidth = CTLineGetTrailingWhitespaceWidth(lineRef);
        
        CGRect lineRect = CGRectMake(lineOrigin.x, lineOrigin.y - descent, width, ascent + descent);
        lineRect.origin.x += _frameRect.origin.x;
        
        // iOS
        lineRect.origin.y = CGRectGetHeight(_frameRect) - CGRectGetMaxY(lineRect);
        
        CGRect drawingRect = lineRect;
        if (0 <= index) {
            // iOS
            drawingRect.origin.y = CGRectGetHeight(_bound) - CGRectGetMaxY(lineRect);
        }
        
        MBLineLayout *lineLayout = [[MBLineLayout alloc] initWithLineRef:lineRef index:index rect:lineRect metrix:metrics];
        lineLayout.drawingRect = drawingRect;
        
        for (MBLinkText *linkText in self.links) {
            CGRect linkRect = [lineLayout rectOfStringWithRange:linkText.textRange];
            if (!CGRectIsEmpty(linkRect)) {
                MBTextGeo *textGeo = [[MBTextGeo alloc] initWithRect:linkRect lineIndex:[NSNumber numberWithInteger:index]];
                [linkText addTextGeometory:textGeo];
                
                [lineLayout addLink:linkText];
            }
        }
        
        [lineLayouts addObject:lineLayout];
        _lineLayouts = lineLayouts;
    }
}

- (void)update
{
    [self createFramesetter];
    [self createFrame];
    
    [self createLink];
    
    [self createLine];
}

#pragma mark -
#pragma mark draw
- (void)drawInContext:(CGContextRef)context
{
    [self drawFrameInContext:context];
}

- (void)drawFrameInContext:(CGContextRef)context
{
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bound));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    NSArray *lineLayouts = self.lineLayouts;
    for (MBLineLayout *lineLayout in lineLayouts) {
        CGRect drawingRect = lineLayout.drawingRect;
        CGContextSetTextPosition(context, drawingRect.origin.x, drawingRect.origin.y + lineLayout.metrics.descent);
        
        CTLineRef lineRef = lineLayout.lineRef;
        CTLineDraw(lineRef, context);
    }
}

#pragma mark -
- (CFIndex)stringIndexForPosition:(CGPoint)point
{
    for (MBLineLayout *layout in self.lineLayouts) {
        if ([layout containsPoint:point]) {
            CFIndex index = [layout stringIndexForPosition:point];
            
            if (index != kCFNotFound) {
                return index;
            }
            
        }
    }
    
    return kCFNotFound;
}

- (CFIndex)stringIndexForClosePosition:(CGPoint)point
{
    NSString *text = self.attributedString.string;
    
    CFIndex lineNumber = 0;
    for (MBLineLayout *lineLayout in self.lineLayouts) {
        if ([lineLayout containsPoint:point]) {
            CFIndex index = [lineLayout stringIndexForPosition:point];
            
            if (index < text.length) {
                unichar cha = [text characterAtIndex:index];
                if (CFStringIsSurrogateLowCharacter(cha)) {
                    index++;
                    if ((0xDDE6 <= cha && cha <= 0xDDFF) || cha == 0x20E3) {
                        index += 2;
                    }
                }
            }
            
            if (index != kCFNotFound) {
                return index;
            }
        }
        
        if (lineNumber == 0 && point.y < CGRectGetMinY(lineLayout.rect)) {
            return 0;
        }
        
        if (lineNumber == self.lineLayouts.count - 1 && point.y > CGRectGetMaxY(lineLayout.rect) - lineLayout.metrics.leading) {
            return [lineLayout stringIndexForPosition:CGPointMake(CGRectGetMaxX(lineLayout.rect), CGRectGetMinY(lineLayout.rect))];
        }
        
        if (point.y > CGRectGetMinY(lineLayout.rect) && point.y < CGRectGetMaxY(lineLayout.rect) - lineLayout.metrics.leading) {
            return [lineLayout stringIndexForPosition:CGPointMake(CGRectGetMaxX(lineLayout.rect), CGRectGetMinY(lineLayout.rect))];
        }
        
        
        lineNumber ++;
    }
    
    return kCFNotFound;
}

- (CGRect)rectOfStringForIndex:(CFIndex)index
{
    return CGRectZero;
}

- (void)setSelectionStartWithPoint:(CGPoint)point
{
    CFIndex index = [self stringIndexForPosition:point];
    if (index != kCFNotFound) {
        self.textSelection = [[MBTextSelection alloc] initWithIndex:index];
    } else {
        self.textSelection = nil;
    }
}

- (void)setSelectionEndWithPoint:(CGPoint)point
{
    CFIndex index = [self stringIndexForClosePosition:point];
    if (index != kCFNotFound) {
        [self.textSelection setSelectionAtEndIndex:index];
    }
}

- (void)setSelectionEndWithClosePoint:(CGPoint)point
{
    CFIndex index = [self stringIndexForClosePosition:point];
    [self.textSelection setSelectionAtEndIndex:index];
}

- (void)setSelectionStartWithFirstPoint:(CGPoint)point
{
    CFIndex start = [self stringIndexForClosePosition:point];
    CFIndex end = NSMaxRange(self.textSelection.selectedRange);

    if (start != kCFNotFound) {
        if (start < end) {
            self.textSelection = [[MBTextSelection alloc] initWithIndex:start];
        } else {
            end = start;
        }
    }
    
    [self.textSelection setSelectionAtEndIndex:end];
}

- (void)setSelectionWithPoint:(CGPoint)point
{
    CFIndex index = [self stringIndexForPosition:point];
    if (index == kCFNotFound) {
        return;
    }
    
    CFStringRef stringRef = (__bridge CFStringRef)self.attributedString.string;
    CFRange stringRange = CFRangeMake(0, CFStringGetLength(stringRef));
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(NULL, stringRef, stringRange, kCFStringTokenizerUnitWordBoundary, NULL);
    CFStringTokenizerTokenType tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0);
    while (tokenType != kCFStringTokenizerTokenNone) {
        stringRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        CFIndex first = stringRange.location;
        CFIndex second = stringRange.location + stringRange.length;
        if (first != kCFNotFound && first <= index && index <= second) {
            self.textSelection = [[MBTextSelection alloc] initWithIndex:first];
            [self.textSelection setSelectionAtEndIndex:second];
            break;
        }
        
        tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
    }
    CFRelease(tokenizer);
}

@end

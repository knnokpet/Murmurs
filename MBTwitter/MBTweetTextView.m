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
#import "MBTextGeo.h"
#import "MBTextSelection.h"

#import "MBSelectionView.h"
#import "MBMagnifierView.h"
#import "MBMagnifierRangeView.h"

typedef NS_ENUM(NSUInteger, MBToucheState) {
    MBToucheStateNone       = 0,
    MBToucheStateBegan      = 1 << 0,
    MBToucheStateMoved      = 1 << 1,
    MBToucheStateStationary = 1 << 2,
    MBToucheStateEnded      = MBToucheStateNone,
    MBToucheStateCancelled  = MBToucheStateNone,
    MBToucheStateTouching   = MBToucheStateBegan | MBToucheStateMoved | MBToucheStateStationary
};

@interface MBTweetTextView()

@property (nonatomic, readonly) MBTextLayout *textLayout;

@property (nonatomic) CGPoint touchedPoint;
@property (nonatomic) MBToucheState toucheState;

@property (nonatomic) MBSelectionView *selectionView;
@property (nonatomic) MBMagnifierView *magnifierView;
@property (nonatomic) MBMagnifierRangeView *magnifierRangeView;

@end

@implementation MBTweetTextView

#pragma mark -
#pragma mark Initialize
- (void)awakeFromNib
{
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    _textLayout = [[MBTextLayout alloc] init];
    _textLayout.bound = self.bounds;
    
    self.linkHighlightColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
    [self setIsSelectable:NO];
    
    [self configureTextSelections];
    self.magnifierView = [[MBMagnifierView alloc] init];
    self.magnifierRangeView = [[MBMagnifierRangeView alloc] init];
}

- (void)configureTextSelections
{
    CGRect frame = self.bounds;
    self.selectionView = [[MBSelectionView alloc] initWithFrame:frame tweetTextView:self];
    self.selectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.selectionView.userInteractionEnabled = NO;
    [self addSubview:self.selectionView];
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setIsSelectable:(BOOL)isSelectable
{
    _isSelectable = isSelectable;
    
    self.selectionView.userInteractionEnabled = YES;
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
}

- (void)setParagraphStyleAttribute
{
    CTTextAlignment alignment;
    if (NSTextAlignmentCenter == self.alignment) {
        alignment = kCTTextAlignmentCenter;
    } else if (NSTextAlignmentRight == self.alignment) {
        alignment = kCTTextAlignmentRight;
    } else {
        alignment = (CTTextAlignment)self.alignment;
    }
    
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
    
    self.textLayout.textAlignment = alignment;
}


- (void)setAttributes:(NSDictionary *)attributes
{
    NSInteger length = self.attributedString.length;
    NSMutableAttributedString *mutableAttributedString = self.attributedString.mutableCopy;
    if (attributes) {
        [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, length)];
    }
    
    _attributedString = mutableAttributedString;
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
    
    [self highlightSelectedText];
    
    [self highlightClickedText];
    
    [self resetSelection];
    
    // draw
    [self.textLayout drawInContext:context];
}

#pragma mark -
- (BOOL)containsPointInTextFrame:(CGPoint)point
{
    return CGRectContainsPoint(self.textLayout.frameRect, point);
}

- (BOOL)containsPointInSelectionFrame:(CGPoint)point
{
    CFIndex index = [self stringIndexAtPoint:point];
    NSRange selectedRange = self.textLayout.textSelection.selectedRange;
    return NSLocationInRange(index, selectedRange);
}

- (CFIndex)stringIndexAtPoint:(CGPoint)point
{
    return [self.textLayout stringIndexForPosition:point];
}

- (void)highlightSelectedText
{
    MBTextSelection *selection = self.textLayout.textSelection;
    NSRange selectedRange = selection.selectedRange;
    if (!selection || NSNotFound == selectedRange.location) {
        return;
    }
    
    NSInteger lineNumber = 0;
    CGRect startRect = CGRectZero;
    CGRect endRect = CGRectZero;
    
    CGFloat lineSpacing = self.lineSpace;
    CGFloat previousLineOffSet = 0.0f;
    
    for (MBLineLayout *lineLayout in self.textLayout.lineLayouts) {
        NSRange stringRange = lineLayout.stringRange;
        
        NSRange intersectionRange = NSIntersectionRange(selectedRange, stringRange);
        if (intersectionRange.location == NSNotFound) {
            continue;
        }
        
        CGRect selectionRect = [lineLayout rectOfStringWithRange:selectedRange];
        if (CGRectIsEmpty(selectionRect)) {
            continue;
        }
        
        [self.selectedTextBackgroundColor set];
        
        selectionRect.origin.y -= lineSpacing;
        selectionRect.size.height += lineSpacing;
        if (selectionRect.origin.y < 0.0f) {
            selectionRect.size.height += selectionRect.origin.y;;
            selectionRect.origin.y = 0.0f;
        }
        
        if (NSMaxRange(selectedRange) != NSMaxRange(stringRange) && NSMaxRange(intersectionRange) == NSMaxRange(stringRange)) {
            selectionRect.size.width = CGRectGetWidth(self.bounds) - CGRectGetMinX(selectionRect);
        }
        
        if (previousLineOffSet > 0.0f) {
            CGFloat delta = CGRectGetMinY(selectionRect) - previousLineOffSet;
            selectionRect.origin.y -= delta;
            selectionRect.size.height += delta;
        }
        
        selectionRect = CGRectIntegral(selectionRect);
        
        UIRectFill(selectionRect);
        
        if (lineNumber == 0) {
            startRect = selectionRect;
            endRect = selectionRect;
        } else {
            endRect = selectionRect;
        }
        
        previousLineOffSet = CGRectGetMaxY(selectionRect);
        
        lineNumber ++;
    }
    
    self.selectionView.startFrame = startRect;
    self.selectionView.endFrame = endRect;
}

- (void)highlightClickedText
{
    if (self.toucheState & MBToucheStateBegan || self.toucheState & MBToucheStateStationary) {
        MBLinkText *linkText = [self linkAtPoint:self.touchedPoint];
        for (MBTextGeo *geo in linkText.geometries) {
            CGRect geoRect = geo.rect;
            
            [self.linkHighlightColor set];
            geoRect.origin.y -= 3;
            geoRect.size.height += 6;
            // 上下端の行だと切れます。
            UIBezierPath *bezierPath = [self bezierPathWithRect:geoRect cornerRadius:4.0f];
            [bezierPath fill];
        }
    }
}

- (UIBezierPath *)bezierPathWithRect:(CGRect)rect cornerRadius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
}

- (void)clickedOnLink:(MBLinkText *)link
{
    if ([_delegate respondsToSelector:@selector(tweetTextView:clickOnLink:point:)]) {
        [_delegate tweetTextView:self clickOnLink:link point:self.touchedPoint];
    }
}

#pragma mark -
- (void)selectionChanged
{
    [self setNeedsDisplayInRect:self.bounds];
}

- (void)clearSelection
{
    self.textLayout.textSelection = nil;
}

- (void)resetSelection
{
    if (!self.isSelectable) {
        [self hideSelectionView];
        return;
    }
    
    if (self.toucheState == MBToucheStateTouching) {
        [self hideSelectionView];
        return;
    }
    
    MBTextLayout *layout = self.textLayout;
    MBTextSelection *selection = layout.textSelection;
    NSRange selectedRange = selection.selectedRange;
    if (!selection || selectedRange.length == 0) {
        [self hideSelectionView];
        return;
    }
    
    [self.selectionView updateGrabbers];
    [self showSelectionView];
}

- (void)showSelectionView
{
    [self.selectionView showViews];
}

- (void)hideSelectionView
{
    [self.selectionView hideViews];
}

- (void)moveMagnifierToPoint:(CGPoint)point
{
    if ([_delegate respondsToSelector:@selector(tweetTextViewShowMagnifier:point:)]) {
        [_delegate tweetTextViewShowMagnifier:self point:point];
    }
}

- (void)hideMagnifierView
{
    if ([_delegate respondsToSelector:@selector(tweetTextViewHideMagnifier:)]) {
        [_delegate tweetTextViewHideMagnifier:self];
    }
}

- (void)moveMagnifierRangeVIewToPoint:(CGPoint)point
{
    if ([_delegate respondsToSelector:@selector(tweetTextViewShowMagnifierRange:point:)]) {
        [_delegate tweetTextViewShowMagnifierRange:self point:point];
    }
}

- (void)hideMagnifierRangeView
{
    if ([_delegate respondsToSelector:@selector(tweetTextViewHideMagnifierRange:)]) {
        [_delegate tweetTextViewHideMagnifierRange:self];
    }
}

- (void)showEditMenu
{
    if (!self.isFirstResponder && !self.selectionView.isFirstResponder) {
        [self.selectionView becomeFirstResponder];
    }
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    menuController.arrowDirection = UIMenuControllerArrowDefault;
    
    CGRect targetRect = [self rectForEditMenu];
    targetRect.origin.x = 100;
    NSLog(@"origin x = %f %f", targetRect.origin.x, targetRect.origin.y);
    UIView *responderView = (self.isFirstResponder) ? self : self.selectionView;
    [menuController setTargetRect:targetRect inView:responderView];
    [menuController setMenuVisible:YES animated:YES];
    
}

- (CGRect)rectForEditMenu
{
    MBTextSelection *selection = self.textLayout.textSelection;
    CGRect topRect = CGRectNull;
    CGFloat minX = CGFLOAT_MAX;
    CGFloat maxX = CGFLOAT_MIN;
    
    for (MBLineLayout *lineLayout in self.textLayout.lineLayouts) {
        CGRect selectionRect = [lineLayout rectOfStringWithRange:selection.selectedRange];
        if (!CGRectIsEmpty(selectionRect)) {
            CGFloat lineSpace = self.lineSpace;
            selectionRect.origin.y -= lineSpace;
            selectionRect.size.height += lineSpace;
            
            if (CGRectIsNull(topRect)) {
                topRect = selectionRect;
            }
            
            minX = MIN(CGRectGetMinX(selectionRect), minX);
            maxX = MAX(CGRectGetMaxX(selectionRect), maxX);
            
            topRect.origin.x = minX;
            topRect.size.width = maxX - minX;
        }
    }
    
    return topRect;
}

- (void)hideEditMenu
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:NO animated:YES];
}

#pragma mark -
- (void)selectionGestureStateChanged:(UILongPressGestureRecognizer *)gestureRecognizer
{
    self.touchedPoint = [gestureRecognizer locationInView:self];
    
    UIGestureRecognizerState currentState = gestureRecognizer.state;
    if (currentState == UIGestureRecognizerStateBegan || currentState == UIGestureRecognizerStateChanged) {
        self.toucheState = MBToucheStateMoved;
        
        [self moveMagnifierToPoint:self.touchedPoint];
        
        [self.textLayout setSelectionWithPoint:self.touchedPoint];
    } else if (currentState == UIGestureRecognizerStateEnded || currentState == UIGestureRecognizerStateCancelled || currentState == UIGestureRecognizerStateFailed) {
        self.toucheState = MBToucheStateNone;
        
        [self hideMagnifierView];
        
    }
    
    [self selectionChanged];
}

- (void)grabberMoved:(UIPanGestureRecognizer *)gestureRecognizer
{
    MBTextSelection *selection = self.textLayout.textSelection;
    if (!selection || !self.isSelectable) {
        return;
    }
    
    self.touchedPoint = [gestureRecognizer locationInView:self];
    self.toucheState = MBToucheStateNone;
    
    MBSelectionGrabber *startGrabber = self.selectionView.startGrabber;
    MBSelectionGrabber *endGrabber = self.selectionView.endGrabber;
    
    UIGestureRecognizerState currentState = gestureRecognizer.state;
    if (currentState == UIGestureRecognizerStateBegan || currentState == UIGestureRecognizerStateChanged) {
        if (gestureRecognizer == self.selectionView.startGrabberGestureRecognizer) {
            
            [self hideEditMenu];
            [self moveMagnifierRangeVIewToPoint:self.touchedPoint];
            [self.textLayout setSelectionStartWithFirstPoint:self.touchedPoint];
        } else { // endGrabberGesture
            
            [self hideEditMenu];
            [self moveMagnifierRangeVIewToPoint:self.touchedPoint];
            [self.textLayout setSelectionEndWithPoint:self.touchedPoint];
        }
    } else if (currentState == UIGestureRecognizerStateEnded || currentState == UIGestureRecognizerStateCancelled || currentState == UIGestureRecognizerStateFailed) {
        
        [self hideMagnifierRangeView];
        [self showEditMenu];
    }
    
    [self selectionChanged];
}

#pragma mark -
#pragma mark touch
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.isSelectable) {
        return [super hitTest:point withEvent:event];
    }
    
    MBLinkText *linkText = [self linkAtPoint:point];
    if (nil != linkText) {
        return [super hitTest:point withEvent:event];
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touche = touches.anyObject;
    
    self.toucheState = MBToucheStateBegan;
    self.touchedPoint = [touche locationInView:self];
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.toucheState = MBToucheStateCancelled;
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    
    self.toucheState = MBToucheStateEnded;
    self.touchedPoint = [touch locationInView:self];
    
    
    if ([self containsPointInSelectionFrame:self.touchedPoint]) {
        ;
    } else {
        [self clearSelection];
    }
    
    if ([self containsPointInTextFrame:self.touchedPoint]) {
        MBLinkText *linkText = [self linkAtPoint:self.touchedPoint];
        if (linkText) {
            self.toucheState = MBToucheStateStationary;
            [self clickedOnLink:linkText];
        }
    }
    
    [self setNeedsDisplay];
}

@end

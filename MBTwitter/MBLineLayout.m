//
//  MBLineLayout.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLineLayout.h"
#import "MBLinkText.h"
#import "MBTextGeo.h"

@implementation MBLineLayout
#pragma mark -
#pragma mark Initialize
- (id)initWithLineRef:(CTLineRef)lineRef index:(NSInteger)index rect:(CGRect)rect metrix:(MBLineMetrics)metrics
{
    self = [super init];
    if (self) {
        _lineRef = CFRetain(lineRef);
        _index = index;
        _rect = rect;
        _metrics = metrics;
        
        _links = [NSArray array];
    }
    
    return self;
}

- (void)dealloc
{
    CFRelease(_lineRef);
}

#pragma mark -
#pragma mark Setter & Getter
- (NSRange)stringRange
{
    CFRange cfLineRange = CTLineGetStringRange(self.lineRef);
    NSRange lineRange = NSMakeRange(cfLineRange.location, cfLineRange.length);
    return lineRange;
}

#pragma mark -
- (BOOL)containsPoint:(CGPoint)point
{
    return CGRectContainsPoint(self.rect, point);
}

- (CFIndex)stringIndexForPosition:(CGPoint)point
{
    point.x -= self.rect.origin.x;
    CFIndex index = CTLineGetStringIndexForPosition(self.lineRef, point);
    return index;
}

- (CGRect)rectOfStringWithRange:(NSRange)range
{
    CGRect rect = CGRectZero;
    NSRange intersect = NSIntersectionRange(self.stringRange, range);
    
    if (intersect.length > 0) {
        CTLineRef lineRef = self.lineRef;
        CGFloat beginOffSet = CTLineGetOffsetForStringIndex(lineRef, intersect.location, NULL);
        CGFloat endOffSet = CTLineGetOffsetForStringIndex(lineRef, NSMaxRange(intersect), NULL);
        
        rect = self.rect;
        endOffSet = rect.size.width - endOffSet;
        rect.origin.x += beginOffSet;
        rect.size.width = (rect.size.width - (beginOffSet + endOffSet));
    }
    
    return rect;
}

- (void)addLink:(MBLinkText *)link
{
    _links = [self.links arrayByAddingObject:link];
}

- (MBLinkText *)linkAtPoint:(CGPoint)point
{
    for (MBLinkText *linkText in self.links) {
        for (MBTextGeo *textGeo in linkText.geometries) {
            if (CGRectContainsPoint(textGeo.rect, point)) {
                return linkText;
            }
        }
    }
    
    return nil;
}

@end

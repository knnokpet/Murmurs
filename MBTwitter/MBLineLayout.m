//
//  MBLineLayout.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLineLayout.h"

@implementation MBLineLayout
#pragma mark -
#pragma mark
- (id)initWithLineRef:(CTLineRef)lineRef index:(NSInteger)index rect:(CGRect)rect metrix:(MBLineMetrics)metrics
{
    self = [super init];
    if (self) {
        _lineRef = CFRetain(lineRef);
        _index = index;
        _rect = rect;
        _metrics = metrics;
    }
    
    return self;
}

- (void)dealloc
{
    CFRelease(_lineRef);
}

@end

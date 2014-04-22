//
//  MBLineLayout.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

typedef struct {
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    CGFloat width;
    double trailingWhiteSpaceWidth;
}MBLineMetrics;

@interface MBLineLayout : NSObject

@property (nonatomic, readonly) CTLineRef lineRef;
@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) MBLineMetrics metrics;
@property (nonatomic) CGRect drawingRect;

- (id)initWithLineRef:(CTLineRef)lineRef index:(NSInteger)index rect:(CGRect)rect metrix:(MBLineMetrics)metrics;

@end

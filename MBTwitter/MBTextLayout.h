//
//  MBTextLayout.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface MBTextLayout : NSObject

@property (nonatomic) NSAttributedString *attributedString;
@property (nonatomic, readonly) NSArray *lineLayouts;

@property (nonatomic) CGRect bound;
@property (nonatomic, readonly) CGRect frameRect;

+ (CGRect)frameRectWithAttributedString:(NSAttributedString *)attributedString constraintSize:(CGSize)constraintSize;

- (id)initWithAttributedString:(NSAttributedString *)attributedString;

- (void)update;

- (void)drawInContext:(CGContextRef)context;

@end

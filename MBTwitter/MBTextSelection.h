//
//  MBTextSelection.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBTextSelection : NSObject

@property (nonatomic) NSRange selectedRange;

- (id)initWithIndex:(NSInteger)index;

- (void)setSelectionAtEndIndex:(NSInteger)index;

@end

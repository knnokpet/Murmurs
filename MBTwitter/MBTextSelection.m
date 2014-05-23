//
//  MBTextSelection.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTextSelection.h"

@interface MBTextSelection()

@property (nonatomic, assign) NSInteger initialIndex;

@end

@implementation MBTextSelection

- (id)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _initialIndex = index;
    }
    
    return self;
}

- (void)setSelectionAtEndIndex:(NSInteger)index
{
    if (self.initialIndex <= index) {
        CFIndex start = self.initialIndex;
        CFIndex end = index;
        _selectedRange = NSMakeRange(start, end - start);
    } else {
        CFIndex start = index;
        CFIndex end = self.initialIndex;
        _selectedRange = NSMakeRange(start, end - start);
    }
}

@end

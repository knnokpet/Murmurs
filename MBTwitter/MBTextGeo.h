//
//  MBTextGeo.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBTextGeo : NSObject

@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) NSNumber *lineIndex;

- (id)initWithRect:(CGRect)rect lineIndex:(NSNumber *)index;

@end

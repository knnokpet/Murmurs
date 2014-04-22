//
//  MBLink.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBTextIndex.h"
#import "NSDictionary+Objects.h"

@interface MBLink : NSObject

@property (nonatomic, readonly) MBTextIndex *textIndex;
@property (nonatomic, readonly) NSString *displayText; // minus "@", "#"

- (id)initWithDictionary:(NSDictionary *)linkDict;
- (void)initializeWithDictionary:(NSDictionary *)dictionary;

- (void)setTextIndex:(MBTextIndex *)textIndex;
- (void)setDisplayText:(NSString *)displayText;

@end

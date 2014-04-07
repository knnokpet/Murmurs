//
//  MBMediaLink.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLink.h"

@interface MBMediaLink : MBLink

@property (nonatomic, readonly) NSNumber *mediaID;
@property (nonatomic, readonly) NSString *mediaIDStr;
@property (nonatomic, readonly) NSDictionary *sizes;
@property (nonatomic, readonly) NSNumber *sourceTweetID;
@property (nonatomic, readonly) NSString *sourceTweetIDStr;
@property (nonatomic, readonly) NSString *type;

@property (nonatomic, readonly) NSString *expandedURLText;
@property (nonatomic, readonly) NSString *originalURLText;
@property (nonatomic, readonly) NSString *originalURLHttpsText;
@property (nonatomic, readonly) NSString *wrappedURLText;

@end

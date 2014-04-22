//
//  MBURLLink.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLink.h"

@interface MBURLLink : MBLink <NSCoding>

@property (nonatomic, readonly) NSString *expandedURLText;
@property (nonatomic, readonly) NSString *wrappedURLText;

@end

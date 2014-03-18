//
//  NSURL+SignatureBased.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SignatureBased)

- (NSString *)URLStringWithoutQueryFromURL:(NSURL *)url;
- (NSString *)URLStringWithoutQuery;

@end

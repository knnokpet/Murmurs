//
//  NSURL+SignatureBased.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "NSURL+SignatureBased.h"

@implementation NSURL (SignatureBased)

- (NSString *)URLStringWithoutQueryFromURL:(NSURL *)url
{
    return [[[url absoluteString] componentsSeparatedByString:@"?"] firstObject];
}

- (NSString *)URLStringWithoutQuery
{
    return [[[self absoluteString] componentsSeparatedByString:@"?"] firstObject];
}

@end

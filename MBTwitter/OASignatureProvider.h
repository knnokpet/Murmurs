//
//  OASignatureProvider.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OASignatureProvider <NSObject>

- (NSString *)name;
- (NSString *)signatureText:(NSString *)text secret:(NSString *)secret;
- (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key;

@end

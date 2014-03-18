//
//  OAHMAC-SHA1SignatureProvider.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/13.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "OAHMAC-SHA1SignatureProvider.h"
#include "hmac.h"
#include "Base64Transcoder.h"

#define HMAC_LENGTH 20;
#define BASE_64_LENGTH 32;

@implementation OAHMAC_SHA1SignatureProvider

- (NSString *)name
{
    return @"HMAC-SHA1";
}

- (NSString *)signatureText:(NSString *)text secret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    int hmacLength = HMAC_LENGTH;
    int base64Length = BASE_64_LENGTH;
    
    unsigned char result[hmacLength];
    hmac_sha1((unsigned char*)[textData bytes], (int)[textData length], (unsigned char *)[secretData bytes], (unsigned int)[secretData length], result);
    
    // Base64Encode
    char base64Result[base64Length];
    size_t baseResultLength = base64Length;
    Base64EncodeData(result, hmacLength, base64Result, &baseResultLength);
    NSData *base64ResultData = [NSData dataWithBytes:base64Result length:base64Length];
    if (base64ResultData == nil) {
        
    }
    
    NSString *signature = [[NSString alloc] initWithData:base64ResultData encoding:NSASCIIStringEncoding];
    if (signature == nil) {
        
    }

    return signature;
}

@end

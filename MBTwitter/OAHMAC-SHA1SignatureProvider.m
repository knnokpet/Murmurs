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
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "Base64.h"

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
    size_t baseResultSize = base64Length;
    Base64EncodeData(result, hmacLength, base64Result, &baseResultSize);
    NSData *base64ResultData = [NSData dataWithBytes:base64Result length:baseResultSize];
    if (base64ResultData == nil) {
        
    }
    
    NSString *signature = [[NSString alloc] initWithData:base64ResultData encoding:NSUTF8StringEncoding];
    if (signature == nil) {
        
    }

    return signature;
}

- (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key
{
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char CHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), CHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:CHMAC length:sizeof(CHMAC)];
    
    NSString *hash = [HMAC base64EncodedString];
    
    return hash;
    
}

@end

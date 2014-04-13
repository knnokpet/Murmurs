//
//  OAMutableRequest.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/12.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OASignatureProvider.h"

@class OAConsumer;
@class OAToken;
@interface OAMutableRequest : NSMutableURLRequest

@property (nonatomic, readonly) OAConsumer *consumer;
@property (nonatomic, readonly) OAToken *token;
@property (nonatomic) id< OASignatureProvider> signatureProvider;
@property (nonatomic, readonly) NSString *signature;
@property (nonatomic, readonly) NSString *nonce;
@property (nonatomic, readonly) NSString *timeStamp;
@property (nonatomic, readonly) NSString *realm;

@property (nonatomic, readonly) NSArray *parameters;

- (id)initWithURL:(NSURL *)URL
         consumer:(OAConsumer *)consumer
            token:(OAToken *)token
            realm:(NSString *)realm
        signatureProvider:(id <OASignatureProvider>)signatureProvider;

- (void)prepareOAuthRequest;
- (void)prepareRequest;

- (NSArray *)parameters;
- (void)setParameters:(NSArray *)parameters;
- (void)setMultiPartPostParameters:(NSDictionary *)parameters;

@end

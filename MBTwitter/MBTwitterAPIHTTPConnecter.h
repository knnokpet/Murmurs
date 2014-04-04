//
//  MBTwitterAPIHTTPConnecter.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBTwitterAPIRequestType.h"

@protocol MBTwitterAPIHTTPConnecterDelegate;
@interface MBTwitterAPIHTTPConnecter : NSObject

@property (nonatomic, weak) id <MBTwitterAPIHTTPConnecterDelegate> delegate;

@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSString *identifier;

- (id)initWithRequest:(NSURLRequest *)urlRequest requestType:(MBRequestType)requestType responseType:(MBResponseType)responseType;

- (void)start;

- (MBRequestType)requestType;
- (MBResponseType)responseType;

@end

@protocol MBTwitterAPIHTTPConnecterDelegate <NSObject>

- (void)failedConnecter:(MBTwitterAPIHTTPConnecter *)connecter error:(NSError *)error responseType:(MBResponseType)responseType;
- (void)finishedConnecter:(MBTwitterAPIHTTPConnecter *)connecter data:(NSData *)data responseType:(MBResponseType)responseType;

@end

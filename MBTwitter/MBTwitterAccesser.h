//
//  MBTwitterAccesser.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBTwitterAccesserDelegate;

@class OAToken;
@class OAConsumer;
@interface MBTwitterAccesser : NSObject

@property (nonatomic, readonly) NSString *consumerKey;
@property (nonatomic, readonly) NSString *consumerSecret;
@property (nonatomic, readonly) NSString *pin;

@property (nonatomic, weak) id <MBTwitterAccesserDelegate> delegate;


- (void)setConsumerKey:(NSString *)consumerKey;
- (void)setConsumerSecret:(NSString *)consumerSecret;
- (void)setPin:(NSString *)pin;

- (BOOL)isAuthorized;
- (NSURLRequest *)authorizeURLRequest;

- (void)requestRequestToken;
- (void)requestAccessToken;

@end


@protocol MBTwitterAccesserDelegate <NSObject>

- (void)getRequestTokenTwitterAccesser:(MBTwitterAccesser *)twitterAccesser;

@end

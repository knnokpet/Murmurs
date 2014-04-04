//
//  MBAccount.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OAToken;
@interface MBAccount : NSObject

@property (nonatomic, readonly) NSString *screenName;
@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) OAToken *accessToken;

- (id)initWithDictionary:(NSDictionary *)accountData;

@end

//
//  MBMentionUserLink.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBLink.h"

@interface MBMentionUserLink : MBLink <NSCoding>

@property (nonatomic, readonly) NSNumber *userID;
@property (nonatomic, readonly) NSString *userIDStr;
@property (nonatomic, readonly) NSString *screenName;

- (instancetype)initWithUserID:(NSNumber *)userID IDStr:(NSString *)IDStr screenName:(NSString *)screenName;/* For linking User On TL */

@end

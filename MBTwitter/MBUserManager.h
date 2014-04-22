//
//  MBUserManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBUser;
@interface MBUserManager : NSObject

+ (MBUserManager *)sharedInstance;

- (MBUser *)storedUserForKey:(NSString *)key;
- (void)storeUser:(MBUser *)user;

@end

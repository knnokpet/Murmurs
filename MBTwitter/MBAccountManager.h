//
//  MBAccountManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

typedef void(^MBAccountManagerRequestCompletionHandler)(BOOL granted, NSArray *accounts, NSError *error);

@class MBAccount;
@interface MBAccountManager : NSObject

@property (nonatomic, readonly) NSArray *accounts;
@property (nonatomic, readonly) MBAccount *currentAccount;

+ (MBAccountManager *)sharedInstance;

- (BOOL)isSelectedAccount;

- (void)requestAccessToAccountWithCompletionHandler:(MBAccountManagerRequestCompletionHandler)completionHandler;
- (void)saveMyAccountWith:(NSDictionary *)myAccount;
- (void)selectAccountAtIndex:(NSInteger )index;
- (void)deleteAllAccount;

@end

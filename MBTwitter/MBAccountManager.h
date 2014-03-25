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

@interface MBAccountManager : NSObject

@property (nonatomic, readonly) NSMutableArray *accounts;

+ (MBAccountManager *)sharedInstance;

- (void)requestAccessToAccountWithCompletionHandler:(MBAccountManagerRequestCompletionHandler)completionHandler;

@end

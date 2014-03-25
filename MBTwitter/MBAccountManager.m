//
//  MBAccountManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAccountManager.h"
#import "MBTwitterAccesser.h"

@implementation MBAccountManager

+ (MBAccountManager *)sharedInstance
{
    static MBAccountManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MBAccountManager alloc] initSharedInstance];
    });
    
    return sharedInstance;
    
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -
- (void)requestAccessToAccountWithCompletionHandler:(MBAccountManagerRequestCompletionHandler)completionHandler
{
    
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^ (BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            if ([accounts count] == 0) {
                completionHandler(NO, nil, error);
                
            } else {
                completionHandler(YES, accounts, error);
                
            }
        } else {
            completionHandler(NO, nil, error);
        }
    }];
}

@end

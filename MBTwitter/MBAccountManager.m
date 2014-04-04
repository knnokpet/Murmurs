//
//  MBAccountManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBTwitterAccesser.h"

#define USER_DEFAULTS_KEY_AOUTH_ACCOUNT @"oauth_data"

@implementation MBAccountManager

#pragma mark -
#pragma mark Initialize
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
        [self updateAccounts];
    }
    
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -
#pragma mark Setter & Getter
- (void)setCurrentAccount:(MBAccount *)currentAccount
{
    _currentAccount = currentAccount;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeMyAccount" object:nil];
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

#pragma mark -
#pragma mark account
- (BOOL)isSelectedAccount
{
    BOOL isSelected = NO;
    if (nil != _currentAccount) {
        isSelected = YES;
    }
    
    return isSelected;
}

- (void)storeMyAccountWith:(NSDictionary *)myAccount
{
    if (!myAccount) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *savingAccounts = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:USER_DEFAULTS_KEY_AOUTH_ACCOUNT]];
    [savingAccounts addObject:myAccount];
    
    [userDefaults setObject:savingAccounts forKey:USER_DEFAULTS_KEY_AOUTH_ACCOUNT];
    
    [self updateAccounts];
}

- (void)updateAccounts
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *storedMyAccounts = [userDefaults arrayForKey:USER_DEFAULTS_KEY_AOUTH_ACCOUNT];
    
    NSMutableArray *accounts = [NSMutableArray array];
    for (NSDictionary *accountData in storedMyAccounts) {
        MBAccount *account = [[MBAccount alloc] initWithDictionary:accountData];
        [accounts addObject:account];
    }
    
    
    _accounts = accounts;
}

- (void)selectAccountAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectedRow = indexPath.row;
    if (selectedRow > [self.accounts count]) {
        return;
    }
    
    [self setCurrentAccount:[self.accounts objectAtIndex:selectedRow]];
    
}

- (void)deleteAllAccount{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:USER_DEFAULTS_KEY_AOUTH_ACCOUNT];
    [self updateAccounts];
}

@end

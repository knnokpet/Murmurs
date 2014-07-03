//
//  MBDirectMessageManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDirectMessageManager.h"
#import "MBTemporaryDirectMessage.h"
#import "MBDirectMessage.h"
#import "MBUser.h"
#import "MBAccountManager.h"
#import "MBAccount.h"

@implementation MBDirectMessageManager
#pragma mark -
#pragma mark Initialize
+ (MBDirectMessageManager *)sharedInstance
{
    static MBDirectMessageManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MBDirectMessageManager alloc] initSharedInstance];
    });
    
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        _dataSource = [NSMutableDictionary dictionary];
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
- (NSArray *)separatedMessages
{
    MBAccount *currentAccount;
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (NO == [accountManager isSelectedAccount]) {
        return nil;
    }
    currentAccount = [accountManager currentAccount];
    
    NSMutableDictionary *myAccountMessages = [self.dataSource objectForKey:currentAccount.userID];
    
    NSMutableArray *separatedMessages = [NSMutableArray arrayWithCapacity:[[myAccountMessages allKeys] count]];
    [myAccountMessages enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSMutableArray class]] && [key isKindOfClass:[NSString class]]) {
            NSMutableArray *mutableArray = (NSMutableArray *)obj;
            MBDirectMessage *message = (MBDirectMessage *)[mutableArray lastObject];
            [separatedMessages addObject:@{@"user" : (NSString *)key, @"messages": mutableArray, @"lastMessageDate": message.createdDate}];
        }
    }];
    
    NSSortDescriptor *sortDescripter = [[NSSortDescriptor alloc] initWithKey:@"lastMessageDate" ascending:NO];
    NSArray *sortedMessages = [separatedMessages sortedArrayUsingDescriptors:@[sortDescripter]];
    
    return sortedMessages;
}

#pragma mark -
#pragma mark Instance Methods

- (void)storeMessage:(MBDirectMessage *)message
{
    if (nil == message) {
        return;
    }
    
    MBAccount *currentAccount;
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (NO == [accountManager isSelectedAccount]) {
        return;
    }
    currentAccount = [accountManager currentAccount];
    NSMutableDictionary *myAccountDictionary = [self.dataSource objectForKey:currentAccount.userID];
    if (!myAccountDictionary) {
        myAccountDictionary = [NSMutableDictionary dictionary];
        [self.dataSource setObject:myAccountDictionary forKey:currentAccount.userID];
    }
    
    MBUser *partner;
    partner = ([message.recipient.userIDStr isEqualToString:currentAccount.userID]) ? message.sender : message.recipient;
    if (!partner || !partner.userIDStr) {
        return; // when deleting message, stop storing message and return here.
    }
    
    NSMutableArray *separatedForUser = [myAccountDictionary objectForKey:partner.userIDStr];
    if (nil == separatedForUser) {
        separatedForUser = [NSMutableArray array];
        [myAccountDictionary setObject:separatedForUser forKey:partner.userIDStr];
    }
    
    [separatedForUser addObject:message];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:YES selector:@selector(compare:)];
    NSMutableArray *sortedMessages = [NSMutableArray arrayWithArray:[separatedForUser sortedArrayUsingDescriptors:@[descriptor]]];
    [myAccountDictionary setObject:sortedMessages forKey:partner.userIDStr];
}

- (NSMutableArray *)separatedMessagesForKey:(NSString *)key
{
    if (nil == key) {
        return nil;
    }
    
    MBAccount *currentAccount;
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (NO == [accountManager isSelectedAccount]) {
        return nil;
    }
    currentAccount = [accountManager currentAccount];
    
    NSMutableDictionary *myAccountMessages = [self.dataSource objectForKey:currentAccount.userID];
    
    return [myAccountMessages objectForKey:key];
    
}

- (void)removeSeparatedMessagesForKey:(NSString *)key
{
    if (nil == key) {
        return;
    }
    
    MBAccount *currentAccount;
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (NO == [accountManager isSelectedAccount]) {
        return;
    }
    currentAccount = [accountManager currentAccount];
    
    NSMutableDictionary *myAccountMessages = [self.dataSource objectForKey:currentAccount.userID];
    [myAccountMessages removeObjectForKey:key];
    
}

@end

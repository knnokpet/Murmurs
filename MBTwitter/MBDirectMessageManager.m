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

static NSString *currentSentMessageKey = @"CurrentSentMessageKey";
static NSString *currentDeliverdMessageKey = @"CurrentDeliverdMessageKey";

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
- (NSMutableDictionary *)messagesSeparatedByAccount
{
    MBAccount *currentAccount;
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (NO == [accountManager isSelectedAccount]) {
        return nil;
    }
    currentAccount = [accountManager currentAccount];
    
    NSMutableDictionary *myAccountDictionary = [self.dataSource objectForKey:currentAccount.userID];
    
    return myAccountDictionary;
}

- (NSArray *)separatedMessages
{
    NSMutableDictionary *myAccountMessages = [self messagesSeparatedByAccount];
    
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
    
    // アカウント毎に保持
    MBAccount *currentAccount;
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (NO == [accountManager isSelectedAccount]) {
        return;
    }
    currentAccount = [accountManager currentAccount];
    NSMutableDictionary *myAccountDictionary = [self.dataSource objectForKey:currentAccount.userID];
    
    if (!myAccountDictionary) {
        myAccountDictionary = [self createAccountDictionary];
    }
    
    // ユーザー毎に保持
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
    
    // 時系列順に整え、self.dataSource-myAccount-someUser として保持
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:YES selector:@selector(compare:)];
    NSMutableArray *sortedMessages = [NSMutableArray arrayWithArray:[separatedForUser sortedArrayUsingDescriptors:@[descriptor]]];
    [myAccountDictionary setObject:sortedMessages forKey:partner.userIDStr];
}

- (NSMutableDictionary *)createAccountDictionary
{
    MBAccount *currentAccount;
    MBAccountManager *accountManager = [MBAccountManager sharedInstance];
    if (NO == [accountManager isSelectedAccount]) {
        return nil;
    }
    currentAccount = [accountManager currentAccount];
    
    NSMutableDictionary *accountDictionary = [NSMutableDictionary dictionary];
    [self.dataSource setObject:accountDictionary forKey:currentAccount.userID];
    
    return accountDictionary;
}

- (MBDirectMessage *)currentSentMessage
{
    NSMutableDictionary *myAccountDictionary = [self messagesSeparatedByAccount];
    if (!myAccountDictionary) {
        myAccountDictionary = [self createAccountDictionary];
    }
    
    MBDirectMessage *sent = [myAccountDictionary objectForKey:currentSentMessageKey];
    
    return sent;
}

- (MBDirectMessage *)currentDeliverdMessage
{
    NSMutableDictionary *myAccountDictionary = [self messagesSeparatedByAccount];
    if (!myAccountDictionary) {
        myAccountDictionary = [self createAccountDictionary];
    }
    
    MBDirectMessage *deliverd = [myAccountDictionary objectForKey:currentDeliverdMessageKey];
    
    return deliverd;
}

- (void)setLatestMessageWithMessages:(NSArray *)messages
{
    MBDirectMessage *latestMessage = [messages firstObject];
    if (!latestMessage) {
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
        myAccountDictionary = [self createAccountDictionary];
    }
    
    
    BOOL isDeliverd;
    isDeliverd = ([latestMessage.recipient.userIDStr isEqualToString:currentAccount.userID]) ? YES : NO;
    if (isDeliverd) {
        [myAccountDictionary setObject:latestMessage forKey:currentDeliverdMessageKey];
    } else {
        [myAccountDictionary setObject:latestMessage forKey:currentSentMessageKey];
    }
}

#pragma mark Methods for separated User
- (NSMutableArray *)separatedMessagesForKey:(NSString *)key
{
    if (nil == key) {
        return nil;
    }
    
    NSMutableDictionary *myAccountMessages = [self messagesSeparatedByAccount];
    
    return [myAccountMessages objectForKey:key];
    
}

- (void)removeSeparatedMessagesForKey:(NSString *)key
{
    if (nil == key) {
        return;
    }
    
    NSMutableDictionary *myAccountMessages = [self messagesSeparatedByAccount];
    [myAccountMessages removeObjectForKey:key];
    
}

@end

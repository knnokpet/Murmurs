//
//  MBDirectMessageManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDirectMessageManager.h"
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
    NSMutableArray *separatedMessages = [NSMutableArray arrayWithCapacity:[[self.dataSource allKeys] count]];
    [self.dataSource enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSMutableArray class]] && [key isKindOfClass:[NSString class]]) {
            NSMutableArray *mutableArray = (NSMutableArray *)obj;
            MBDirectMessage *message = (MBDirectMessage *)[mutableArray firstObject];
            NSLog(@"created = %@", message.createdDate);
            [separatedMessages addObject:@{@"user" : (NSString *)key, @"messages": mutableArray, @"firstMessageDate": message.createdDate}];
        }
    }];
    
    NSSortDescriptor *sortDescripter = [[NSSortDescriptor alloc] initWithKey:@"firstMessageDate" ascending:YES];
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
    
    MBUser *partner;
    partner = ([message.recipient.userIDStr isEqualToString:currentAccount.userID]) ? message.sender : message.recipient;
    
    NSMutableArray *separatedForUser = [self.dataSource mutableArrayForKey:partner.userIDStr];
    if (nil == separatedForUser) {
        separatedForUser = [NSMutableArray array];
    }
    [separatedForUser addObject:message];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:YES selector:@selector(compare:)];
    NSMutableArray *sortedMessages = [NSMutableArray arrayWithArray:[separatedForUser sortedArrayUsingDescriptors:@[descriptor]]];
    [self.dataSource setObject:sortedMessages forKey:partner.userIDStr];
}

- (NSMutableArray *)separatedMessagesForKey:(NSString *)key
{
    if (nil == key) {
        return nil;
    }
    
    return [self.dataSource mutableArrayForKey:key];
}

- (void)removeSeparatedMessagesForKey:(NSString *)key
{
    if (nil == key) {
        return;
    }
    
    [self.dataSource removeObjectForKey:key];
}

@end

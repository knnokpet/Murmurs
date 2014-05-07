//
//  MBDirectMessageManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBDirectMessage;
@interface MBDirectMessageManager : NSObject

@property (nonatomic, readonly) NSMutableDictionary *dataSource;

+ (MBDirectMessageManager *)sharedInstance;

- (NSArray *)separatedMessages;
- (void)storeMessage:(MBDirectMessage *)message;
- (NSMutableArray *)separatedMessagesForKey:(NSString *)key;
- (void)removeSeparatedMessagesForKey:(NSString *)key;

@end

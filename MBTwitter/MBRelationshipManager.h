//
//  MBRelationshipManager.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBRelationship;
@interface MBRelationshipManager : NSObject

- (NSArray *)requiredLoadingRelationshipUserIDs:(NSUInteger)numberOfUserIDs;
- (void)addRequiredLoadingRelationshipUserID:(NSNumber *)userID;
- (void)storeRelationship:(MBRelationship *)relationship;
- (MBRelationship *)storedRelationship:(NSNumber *)userID;
- (void)removeRelationship:(NSNumber *)userID;

@end

//
//  MBRelationshipManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/14.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBRelationshipManager.h"
#import "MBRelationship.h"

@interface MBRelationshipManager()

@property (nonatomic, readonly) NSMutableDictionary *nonRelationshipUserIDs;
@property (nonatomic, readonly) NSMutableDictionary *relationships;

@end

@implementation MBRelationshipManager

- (id)init
{
    self = [super init];
    if (self) {
        _nonRelationshipUserIDs = [NSMutableDictionary dictionary];
        _relationships = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark -
- (NSArray *)requiredLoadingRelationshipUserIDs:(NSUInteger)numberOfUserIDs
{
    NSMutableArray *userIDs = [NSMutableArray array];
    NSInteger i = 0;
    for (NSNumber *userID in [self.nonRelationshipUserIDs allValues]) {
        if (i < numberOfUserIDs) {
            [userIDs addObject:userID];
            
            i++;
        } else {
            break;
        }
    }
    
    
    return userIDs;
}
- (void)addRequiredLoadingRelationshipUserID:(NSNumber *)userID
{
    if (!userID) {
        return;
    }
    
    [self.nonRelationshipUserIDs setObject:userID forKey:userID];
}

- (MBRelationship *)storedRelationship:(NSNumber *)userID
{
    if (!userID) {
        return nil;
    }
    
    MBRelationship *storedRelationship = [self.relationships objectForKey:userID];
    return storedRelationship;
}

- (void)storeRelationship:(MBRelationship *)relationship
{
    if (!relationship && !relationship.userID) {
        return;
    }
    
    [self.nonRelationshipUserIDs removeObjectForKey:relationship.userID];
    
    [self.relationships setObject:relationship forKey:relationship.userID];
}

- (void)removeRelationship:(NSNumber *)userID
{
    [self.relationships removeObjectForKey:userID];
}

@end

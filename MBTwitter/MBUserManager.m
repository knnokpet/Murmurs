//
//  MBUserManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUserManager.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "MBRelationshipManager.h"
#import "MBUser.h"

@interface MBUserManager()

@property (nonatomic, readonly) NSMutableDictionary *users;

@end

@implementation MBUserManager
#pragma mark -
#pragma mark Initialize
+ (MBUserManager *)sharedInstance
{
    static MBUserManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MBUserManager alloc] initSharedInstance];
    });
    
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        _users = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -
#pragma mark
- (MBUser *)storedUserForKey:(NSString *)key
{
    if (nil == key) {
        return nil;
    }
    MBUser *user = [self.users objectForKey:key];
    if (nil == user) {
        return nil;
    }
    
    [self setRelationshipForUser:user];
    
    return user;
}

- (void)storeUser:(MBUser *)user
{
    if (nil == user) {
        return ;
    }
    
    NSString *key = user.userIDStr;
    if (!key) {
        return;
    }
    
    [self setRelationshipForUser:user];
    
    [self.users setObject:user forKey:key];
}

- (void)setRelationshipForUser:(MBUser *)user
{
    MBRelationshipManager *currentRelationshipManager = [[MBAccountManager sharedInstance].currentAccount relationshipManger];
    user.relationship = [currentRelationshipManager storedRelationship:user.userID];
    if (!user.relationship) {
        [currentRelationshipManager addRequiredLoadingRelationshipUserID:user.userID];
    } else {
        // userObject が単体でくるような、フォローフォロー解除のときのみ更新する？
        //[self.relationshipManager removeRelationship:user.userID];
    }
}

@end

//
//  MBAccount.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Objects.h"

@class MBUserIDManager;
@class MBRelationshipManager;
@class MBTimeLineManager;
@class MBListManager;
@class OAToken;
@interface MBAccount : NSObject

// アカウントごとに変更、保持するため
@property (nonatomic, readonly) MBUserIDManager *followerIDManager;
@property (nonatomic, readonly) MBRelationshipManager *relationshipManger;
@property (nonatomic, readonly) MBTimeLineManager *timelineManager;
@property (nonatomic, readonly) MBTimeLineManager *replyTimelineManager;
@property (nonatomic, readonly) MBListManager *listManager;

@property (nonatomic, readonly) NSString *screenName;
@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) OAToken *accessToken;


- (id)initWithDictionary:(NSDictionary *)accountData;

@end

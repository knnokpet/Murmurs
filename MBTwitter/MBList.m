//
//  MBList.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBList.h"
#import "MBUser.h"

#import "NSDictionary+Objects.h"
#import "NSDate+strptime.h"


#define KEY_SLUG @"slug"
#define KEY_NAME @"name"
#define KEY_FULL_NAME @"full_name"
#define KEY_CREATED_AT @"created_at"
#define KEY_URL @"url"
#define KEY_SUBSCRIBER_COUNT @"subscriber_count"
#define KYE_MEMBERS_COUNT @"member_count"
#define KEY_ID @"id"
#define KEY_ID_STR @"id_str"
#define KEY_MEMBER_COUNT @"member_count"
#define KEY_MODE @"mode"
#define KEY_DESCRIPTION @"description"
#define KEY_USER @"user"
#define KEY_MODE @"mode"
#define KEY_FOLLOWING @"following"

@implementation MBList
- (id)initWithDictionary:(NSDictionary *)list
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:list];
        _memberIDs = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)list
{
    _slug = [list stringForKey:KEY_SLUG];
    _name = [list stringForKey:KEY_NAME];
    _fullName = [list stringForKey:KEY_FULL_NAME];
    _createdDate = [NSDate parseDateUsingStrptime:[list stringForKey:KEY_CREATED_AT]];
    _url = [list stringForKey:KEY_URL];
    _subscriber = [list integerForKey:KEY_SUBSCRIBER_COUNT];
    _members = [list integerForKey:KEY_MEMBER_COUNT];
    _listID = [list numberForKey:KEY_ID];
    _listIDStr = [list stringForKey:KEY_ID_STR];
    _description = [list stringForKey:KEY_DESCRIPTION];
    _user = [[MBUser alloc] initWithDictionary:[list objectForKey:KEY_USER]];
    _isFollowing = [list boolForKey:KEY_FOLLOWING];
    
    NSString *mode = [list stringForKey:KEY_MODE];
    if ([mode isEqualToString:@"public"]) {
        _isPublic = YES;
    } else {
        _isPublic = NO;
    }
    
}

@end

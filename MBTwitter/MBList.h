//
//  MBList.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBUser;
@interface MBList : NSObject

@property (nonatomic, readonly) NSString *slug;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSDate *createdDate;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSInteger subscriber;
@property (nonatomic, readonly) NSInteger listID;
@property (nonatomic, readonly) NSString *listIDStr;
@property (nonatomic, readonly) NSString *description;
@property (nonatomic, readonly) MBUser *user;
@property (nonatomic, assign, readonly) BOOL isFollowing;

- (id)initWithDictionary:(NSDictionary *)list;

@end

//
//  MBUser.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Objects.h"

@class MBTweet;
@class MBEntity;
@interface MBUser : NSObject

@property (nonatomic, readonly) NSString *screenName;
@property (nonatomic, readonly) NSNumber *userID;
@property (nonatomic, readonly) NSString *userIDStr;
@property (nonatomic, readonly) NSString *desctiprion;// NULLable
@property (nonatomic, readonly) NSInteger tweetCount;
@property (nonatomic, readonly) NSInteger listedCount;
@property (nonatomic, readonly) NSInteger favoritesCount;
@property (nonatomic, readonly) NSInteger followersCount;
@property (nonatomic, readonly) NSInteger followsCount;
@property (nonatomic, readonly) NSString *location;// NULLable
@property (nonatomic, readonly) NSString *characterName;
@property (nonatomic, readonly) NSDate *createdDate;
@property (nonatomic, readonly) MBEntity *entity;
@property (nonatomic, readonly) MBTweet *currentTweet; // Nullable
@property (nonatomic, readonly) NSString *timeZone; // Nullable
@property (nonatomic, readonly) NSString *language;


@property (nonatomic, assign, readonly) BOOL isVerified;
@property (nonatomic, assign, readonly) BOOL isProtected;
@property (nonatomic, assign, readonly) BOOL isSentRequestToProtectedUser;// NULLable
@property (nonatomic, assign, readonly) BOOL isEnabledContributors;
@property (nonatomic, assign, readonly) BOOL isEnabledGeo;
@property (nonatomic, assign, readonly) BOOL isTranslator;
@property (nonatomic, assign, readonly) BOOL isDefaultProfile;
@property (nonatomic, assign, readonly) BOOL isDefaultProfileImage;
@property (nonatomic, assign, readonly) BOOL isUsedUploadedBackgroundImage;
@property (nonatomic, assign, readonly) BOOL isShownMediaInline;
@property (nonatomic, assign, readonly) BOOL isTileAtProfileBackgound;


@property (nonatomic, readonly) NSString *hexAtProfileBackgoundColor;
@property (nonatomic, readonly) NSString *urlAtProfileBackgoundImage;
@property (nonatomic, readonly) NSString *ulrHTTPSAtProfileBackgoundImage;
@property (nonatomic, readonly) NSString *urlAtProfileBanner;
@property (nonatomic, readonly) NSString *urlAtProfileImage;
@property (nonatomic, readonly) NSString *urlHTTPSAtProfileImage;
@property (nonatomic, readonly) NSString *hexAtProfileLinkColor;
@property (nonatomic, readonly) NSString *hexAtProfileSidebarBoarderColor;
@property (nonatomic, readonly) NSString *hexAtProfileSidebarFillColor;
@property (nonatomic, readonly) NSString *hexAtProfileTextColor;


@property (nonatomic, readonly) NSString *urlAtProfile; // Nullable
@property (nonatomic, readonly) NSInteger utcOffset; // Nullable
@property (nonatomic, readonly) NSString *withheldInCountries;
@property (nonatomic, readonly) NSString *withheldScope;

- (id)initWithDictionary:(NSDictionary *)user;

@end

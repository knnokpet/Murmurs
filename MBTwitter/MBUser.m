//
//  MBUser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUser.h"
#import "MBTweet.h"
#import "MBEntity.h"

#define KEY_SCREEN_NAME @"screen_name"
#define KEY_USER_ID @"id"
#define KEY_USER_ID_STR @"id_str"
#define KEY_DESCRIPTION @"description"
#define KEY_TWEET_COUNT @"statuses_count"
#define KEY_LIST_COUNT @"listed_count"
#define KEY_FAVORITE_COUNT @"favourites_count"
#define KEY_FOLLOWER_COUNT @"followers_count"
#define KEY_FOLLOWING_COUNT @"friends_count"
#define KEY_LOCATION @"location"
#define KEY_CHARACTER_NAME @"name"
#define KEY_CREATED_AT_TIME @"created_at"
#define KEY_ENTITY @"entities"
#define KEY_ENTITY_URL @"url"
#define KEY_TIME_ZONE @"time_zone"
#define KEY_LANGUAGE @"lang"
#define KEY_VERIFIED @"verified"
#define KEY_PROTECTED @"protected"
#define KEY_FOLLOW_REQUEST_SENT @"follow_request_sent"
#define KEY_IS_FOLLOWING @"following"
#define KEY_CONTRIBUTORS_ENBLED @"contributors_enabled"
#define KEY_GEO_ENABLED @"geo_enabled"
#define KEY_IS_TRANSLATOR @"is_translator"
#define KEY_DEFAULT_PROFILE @"default_profile"
#define KEY_DEFAULT_PROFILE_IMAGE @"default_profile_image"
#define KEY_PROFILE_USE_BACKGROUND_IMAGE @"profile_use_background_image"
#define KEY_SHOW_INLINE_MEDIA @"show_all_inline_media"
#define KEY_PROFILE_BACKGROUND_TILE @"profile_background_tile"
#define KEY_PROFILE_IMAGE_URL_HTTPS @"profile_image_url_https"
#define KEY_PROFILE_IMAGE_BANNER_URL_HTTPS @"profile_banner_url"

@implementation MBUser
- (id)initWithDictionary:(NSDictionary *)user
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:user];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)user
{
    _screenName = [user stringForKey:KEY_SCREEN_NAME];
    _userID = [user numberForKey:KEY_USER_ID];
    _userIDStr = [user stringForKey:KEY_USER_ID_STR];
    _desctiprion = [user stringForKey:KEY_DESCRIPTION];
    _tweetCount = [user integerForKey:KEY_TWEET_COUNT];
    _listedCount = [user integerForKey:KEY_LIST_COUNT];
    _favoritesCount = [user integerForKey:KEY_FAVORITE_COUNT];
    _followersCount = [user integerForKey:KEY_FOLLOWER_COUNT];
    _followsCount = [user integerForKey:KEY_FOLLOWING_COUNT];
    _location = [user stringForKey:KEY_LOCATION];
    _characterName = [user stringForKey:KEY_CHARACTER_NAME];
    NSString *createdDateStr = [user stringForKey:KEY_CREATED_AT_TIME];
    _createdDate = [NSDate parseDateUsingStrptime:createdDateStr];
    _entity = [[MBEntity alloc] initWithDictionary:[[user dictionaryForKey:KEY_ENTITY] dictionaryForKey:KEY_ENTITY_URL]];
    // バグる。多分、延々と潜り続けた初期化をするから。
    //NSDictionary *currentTweetDict = [user dictionaryForKey:@"status"];
    //_currentTweet = (currentTweetDict == (id)[NSNull null]) ? nil : [[MBTweet alloc] initWithDictionary:currentTweetDict];
    _timeZone = [user stringForKey:KEY_TIME_ZONE];
    _language = [user stringForKey:KEY_LANGUAGE];
    
    _isVerified = [user boolForKey:KEY_VERIFIED];
    _isProtected = [user boolForKey:KEY_PROTECTED];
    _isSentRequestToProtectedUser = [user boolForKey:KEY_FOLLOW_REQUEST_SENT];
    _isFollowing = [user boolForKey:KEY_IS_FOLLOWING];
    _isEnabledContributors = [user boolForKey:KEY_CONTRIBUTORS_ENBLED];
    _isEnabledGeo = [user boolForKey:KEY_GEO_ENABLED];
    _isTranslator = [user boolForKey:KEY_IS_TRANSLATOR];
    _isDefaultProfile = [user boolForKey:KEY_DEFAULT_PROFILE];
    _isDefaultProfileImage = [user boolForKey:KEY_DEFAULT_PROFILE_IMAGE];
    _isUsedUploadedBackgroundImage = [user boolForKey:KEY_PROFILE_USE_BACKGROUND_IMAGE];
    _isShownMediaInline = [user boolForKey:KEY_SHOW_INLINE_MEDIA];
    _isTileAtProfileBackgound = [user boolForKey:KEY_PROFILE_BACKGROUND_TILE];
    
        
    _urlHTTPSAtProfileImage = [user stringForKey:KEY_PROFILE_IMAGE_URL_HTTPS];
    _urlAtProfileBanner = [user stringForKey:KEY_PROFILE_IMAGE_BANNER_URL_HTTPS];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _screenName = [aDecoder decodeObjectForKey:KEY_SCREEN_NAME];
        _userID = [aDecoder decodeObjectForKey:KEY_USER_ID];
        _userIDStr = [aDecoder decodeObjectForKey:KEY_USER_ID_STR];
        _characterName = [aDecoder decodeObjectForKey:KEY_CHARACTER_NAME];
        _urlHTTPSAtProfileImage = [aDecoder decodeObjectForKey:KEY_PROFILE_IMAGE_URL_HTTPS];
        _requireLoading = YES;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_screenName forKey:KEY_SCREEN_NAME];
    [aCoder encodeObject:_userID forKey:KEY_USER_ID];
    [aCoder encodeObject:_userIDStr forKey:KEY_USER_ID_STR];
    [aCoder encodeObject:_characterName forKey:KEY_CHARACTER_NAME];
    [aCoder encodeObject:_urlHTTPSAtProfileImage forKey:KEY_PROFILE_IMAGE_URL_HTTPS];
}

@end

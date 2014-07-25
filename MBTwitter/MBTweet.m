//
//  MBTweet.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweet.h"
#import "MBUser.h"
#import "MBEntity.h"
#import "MBPlace.h"


#define KEY_TWEET_USER @"user"
#define KEY_PLACE @"place"
#define KEY_FAVORITE_COUNT @"favorite_count"
#define KEY_RETWEET_COUNT @"retweet_count"
#define KEY_FAVORITED @"favorited"
#define KEY_RETWEETED @"retweeted"
#define KEY_TRUNCATED @"truncated"
#define KEY_POSSIBLY_SENSITIVE @"possibly_sensitive"
#define KEY_RETWEETED_ORIGINAL_TWEET @"retweeted_status"
#define KEY_CURRENT_USER_RETWEETED_TWEET @"current_user_retweet"

#define KEY_IN_REPLY_TO_SCREEN_NAME @"in_reply_to_screen_name"
#define KEY_ID_REPLY_TO_TWEET_ID @"in_reply_to_status_id"
#define KEY_ID_REPLY_TO_TWEET_ID_STR @"in_reply_to_status_id_str"
#define KEY_IN_REPLY_TO_USER_ID @"in_reply_to_user_id"
#define KEY_IN_REPLY_TO_USER_ID_STR @"in_reply_to_user_id_str"
#define KEY_LANGUAGE @"lang"
#define KEY_FILTER_LEVEL @"filter_level"

@implementation MBTweet
#pragma mark -
#pragma Initialize
- (id)initWithDictionary:(NSDictionary *)tweet
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:tweet];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)tweet
{
    _tweetText = [tweet stringForKey:KEY_TWEET_TEXT];
    _tweetID = [tweet numberForKey:KEY_TWEET_ID];
    _tweetIDStr = [tweet stringForKey:KEY_TWEET_ID_STR];
    _tweetUser = [[MBUser alloc] initWithDictionary:[tweet dictionaryForKey:KEY_TWEET_USER]];
    NSString *dateStr = [tweet stringForKey:KEY_CREATED_AT_TIME];
    _createdDate = [NSDate parseDateUsingStrptime:dateStr];
    
    _entity = [[MBEntity alloc] initWithDictionary:[tweet dictionaryForKey:KEY_ENTITY]];
    NSDictionary *placeDict = [tweet dictionaryForKey:KEY_PLACE];
    if (placeDict) {
        _place = [[MBPlace alloc] initWithDictionary:placeDict];
    } else {
        _place = nil;
    }
    
    _favoritedCount = [tweet integerForKey:KEY_FAVORITE_COUNT];
    _retweetedCount = [tweet integerForKey:KEY_RETWEET_COUNT];
    
    _isFavorited = [tweet boolForKey:KEY_FAVORITED];
    _isRetweeted = [tweet boolForKey:KEY_RETWEETED];
    if (YES == _isRetweeted) {
        _currentUserRetweetedTweet = [tweet dictionaryForKey:KEY_CURRENT_USER_RETWEETED_TWEET];
    }
    _isTruncated = [tweet boolForKey:KEY_TRUNCATED];
    _isContainedTweetLink = [tweet boolForKey:KEY_POSSIBLY_SENSITIVE];
    
    if (nil != [tweet dictionaryForKey:KEY_RETWEETED_ORIGINAL_TWEET]) {
        _tweetOfOriginInRetweet = [[MBTweet alloc] initWithDictionary:[tweet dictionaryForKey:KEY_RETWEETED_ORIGINAL_TWEET]];
    } else {
        _tweetOfOriginInRetweet = nil;
    }
    
    
    _screenNameOfOriginInReply = [tweet stringForKey:KEY_IN_REPLY_TO_SCREEN_NAME];
    _tweetIDOfOriginInReply = [tweet numberForKey:KEY_ID_REPLY_TO_TWEET_ID];
    _tweetIDStrOfOriginInReply = [tweet stringForKey:KEY_ID_REPLY_TO_TWEET_ID_STR];
    _userIDOfOriginInReply = [tweet numberForKey:KEY_IN_REPLY_TO_USER_ID];
    _userIDStrOfOriginInReply = [tweet stringForKey:KEY_IN_REPLY_TO_USER_ID_STR];
    
    _language = [tweet stringForKey:KEY_LANGUAGE];
    _filterLebel = [tweet stringForKey:KEY_FILTER_LEVEL];
}

#pragma mark Archive
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _tweetText = [aDecoder decodeObjectForKey:KEY_TWEET_TEXT];
        _tweetID = [aDecoder decodeObjectForKey:KEY_TWEET_ID];
        _tweetIDStr = [aDecoder decodeObjectForKey:KEY_TWEET_ID_STR];
        _tweetUser = [aDecoder decodeObjectForKey:KEY_TWEET_USER];
        _createdDate = [aDecoder decodeObjectForKey:KEY_CREATED_AT_TIME];
        _entity = [aDecoder decodeObjectForKey:KEY_ENTITY];
        _place = [aDecoder decodeObjectForKey:KEY_PLACE];
        
        NSNumber *favoriteCount = [aDecoder decodeObjectForKey:KEY_FAVORITE_COUNT];
        _favoritedCount = [favoriteCount integerValue];
        NSNumber *retweetCount = [aDecoder decodeObjectForKey:KEY_RETWEET_COUNT];
        _retweetedCount = [retweetCount integerValue];
        
        NSNumber *isFavorited = [aDecoder decodeObjectForKey:KEY_FAVORITED];
        _isFavorited = [isFavorited boolValue];
        NSNumber *isRetweeted = [aDecoder decodeObjectForKey:KEY_RETWEETED];
        _isRetweeted = [isRetweeted boolValue];
        NSNumber *isTruncated = [aDecoder decodeObjectForKey:KEY_TRUNCATED];
        _isTruncated = [isTruncated boolValue];
        NSNumber *isContainedLink = [aDecoder decodeObjectForKey:KEY_POSSIBLY_SENSITIVE];
        _isContainedTweetLink = [isContainedLink boolValue];
        
        _tweetOfOriginInRetweet = [aDecoder decodeObjectForKey:KEY_RETWEETED_ORIGINAL_TWEET];
        
        _screenNameOfOriginInReply = [aDecoder decodeObjectForKey:KEY_IN_REPLY_TO_SCREEN_NAME];
        _tweetIDOfOriginInReply = [aDecoder decodeObjectForKey:KEY_ID_REPLY_TO_TWEET_ID];
        _tweetIDStrOfOriginInReply = [aDecoder decodeObjectForKey:KEY_ID_REPLY_TO_TWEET_ID_STR];
        _userIDOfOriginInReply = [aDecoder decodeObjectForKey:KEY_IN_REPLY_TO_USER_ID];
        _userIDStrOfOriginInReply = [aDecoder decodeObjectForKey:KEY_IN_REPLY_TO_USER_ID_STR];
        
        _language = [aDecoder decodeObjectForKey:KEY_LANGUAGE];
        _filterLebel = [aDecoder decodeObjectForKey:KEY_FILTER_LEVEL];
        
        _requireLoading = YES;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_tweetText forKey:KEY_TWEET_TEXT];
    [aCoder encodeObject:_tweetID forKey:KEY_TWEET_ID];
    [aCoder encodeObject:_tweetIDStr forKey:KEY_TWEET_ID_STR];
    [aCoder encodeObject:_tweetUser forKey:KEY_TWEET_USER];
    [aCoder encodeObject:_createdDate forKey:KEY_CREATED_AT_TIME];
    [aCoder encodeObject:_entity forKey:KEY_ENTITY];
    [aCoder encodeObject:_place forKey:KEY_PLACE];
    
    NSNumber *favoriteCount = [NSNumber numberWithInteger:_favoritedCount];
    [aCoder encodeObject:favoriteCount forKey:KEY_FAVORITE_COUNT];
    NSNumber *retweetCount = [NSNumber numberWithInteger:_retweetedCount];
    [aCoder encodeObject:retweetCount forKey:KEY_RETWEET_COUNT];
    
    NSNumber *isFavorited = [NSNumber numberWithBool:_isFavorited];
    [aCoder encodeObject:isFavorited forKey:KEY_FAVORITED];
    NSNumber *isRetweeted = [NSNumber numberWithBool:_isRetweeted];
    [aCoder encodeObject:isRetweeted forKey:KEY_RETWEETED];
    NSNumber *isTruncated = [NSNumber numberWithBool:_isTruncated];
    [aCoder encodeObject:isTruncated forKey:KEY_TRUNCATED];
    NSNumber *isContainedLink = [NSNumber numberWithBool:_isContainedTweetLink];
    [aCoder encodeObject:isContainedLink forKey:KEY_POSSIBLY_SENSITIVE];
    
    if (nil != _tweetOfOriginInRetweet) {
        [aCoder encodeObject:_tweetOfOriginInRetweet forKey:KEY_RETWEETED_ORIGINAL_TWEET];
    }
    
    
    [aCoder encodeObject:_screenNameOfOriginInReply forKey:KEY_IN_REPLY_TO_SCREEN_NAME];
    [aCoder encodeObject:_tweetIDOfOriginInReply forKey:KEY_ID_REPLY_TO_TWEET_ID];
    [aCoder encodeObject:_tweetIDStrOfOriginInReply forKey:KEY_ID_REPLY_TO_TWEET_ID_STR];
    [aCoder encodeObject:_userIDOfOriginInReply forKey:KEY_IN_REPLY_TO_USER_ID];
    [aCoder encodeObject:_userIDStrOfOriginInReply forKey:KEY_IN_REPLY_TO_USER_ID_STR];
    
    [aCoder encodeObject:_language forKey:KEY_LANGUAGE];
    [aCoder encodeObject:_filterLebel forKey:KEY_FILTER_LEVEL];
}

@end

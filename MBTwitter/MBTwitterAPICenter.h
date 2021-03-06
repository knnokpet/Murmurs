//
//  MBTwitterAPICenter.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBTwitterAPIHTTPConnecter.h"
#import "MBTwitterAPIRequestType.h"

#define HTTP_POST_METHOD @"POST"
#define HTTP_GET_METHOD @"GET"

#define DEFAULT_CONNECTION_TYPE @"https"
#define DEFAULT_API_DOMAIN @"api.twitter.com"
#define DEFAULT_API_VERSION @"1.1"
#define DEFAULT_API_EXTEND @"json"

#define TWEET_TEXT_LENGTH_MINIMUM 1
#define TWEET_TEXT_LENGTH_MAX 140

@interface MBTwitterAPICenter : NSObject < MBTwitterAPIHTTPConnecterDelegate >

@property (nonatomic) NSMutableDictionary *connections;

- (NSString *)sendRequestMethod:(NSString *)method resource:(NSString *)resource parameters:(NSDictionary *)parameters requestType:(MBRequestType)requestType responseType:(MBResponseType)responseType;

- (void)parseJSONData:(NSData *)jsonData responseType:(MBResponseType)responseType;

#pragma mark -
#pragma mark API Methods
- (NSString *)getBackHomeTimeLineMaxID:(unsigned long long)max;
- (NSString *)getForwardHomeTimeLineSinceID:(unsigned long long)since;
- (NSString *)getHomeTimeLineSinceID:(unsigned long long)since maxID:(unsigned long long)max;

- (NSString *)getBackReplyTimelineMaxID:(unsigned long long)max;
- (NSString *)getForwardReplyTimelineSinceID:(unsigned long long)since;
- (NSString *)getReplyTimelineSinceID:(unsigned long long)since maxID:(unsigned long long)max;

- (NSString *)getBackUserTimelineUserID:(unsigned long long)userID screenName:(NSString *)screenName maxID:(unsigned long long)max;
- (NSString *)getForwardUserTimelineUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since;
- (NSString *)getUserTimelineUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since maxID:(unsigned long long)max;

- (NSString *)getTweet:(unsigned long long)requireID;
- (NSString *)postTweet:(NSString *)tweetText;
- (NSString *)postTweet:(NSString *)tweetText withMedia:(NSArray *)mediaImages;
- (NSString *)postTweet:(NSString *)tweetText inReplyTo:(NSArray *)acountIDs place:(NSDictionary *)place media:(NSArray *)media;
- (NSString *)postDestroyTweetForTweetID:(unsigned long long)tweetID;
- (NSString *)postRetweetForTweetID:(unsigned long long)retweetID;

- (NSString *)getSearchedTweetsWithQuery:(NSString *)query;
- (NSString *)getSearchedTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD sinceID:(unsigned long long)since;
- (NSString *)getSearchedTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD maxID:(unsigned long long)max;
- (NSString *)getSearchedTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD sinceID:(unsigned long long)since maxID:(unsigned long long)max;
- (NSString *)getSearchedRecentTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD sinceID:(unsigned long long)since;
- (NSString *)getSearchedRecentTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD maxID:(unsigned long long)max;
- (NSString *)getSearchedRecentTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD sinceID:(unsigned long long)since maxID:(unsigned long long)max;
- (NSString *)getSearchedPopularTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD sinceID:(unsigned long long)since;
- (NSString *)getSearchedPopularTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD maxID:(unsigned long long)max;
- (NSString *)getSearchedPopularTweetsWithQuery:(NSString *)query geocode:(NSDictionary *)geocode resultLang:(NSString *)langISO639_1 langOfQuery:(NSString *)lang untilDate:(NSString *)YYYY_MM_DD sinceID:(unsigned long long)since maxID:(unsigned long long)max;

- (NSString *)getBackFavoritesForUserID:(unsigned long long)userID screenName:(NSString *)screenName maxID:(unsigned long long)max;
- (NSString *)getForwardFavoritesForUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since;
- (NSString *)getFavoritesForUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since maxID:(unsigned long long)max;
- (NSString *)postFavoriteForTweetID:(unsigned long long)favoriteTweetID;
- (NSString *)postDestroyFavoriteForTweetID:(unsigned long long)destroyTweetID;

- (NSString *)postFollowForUserID:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)postUnfollowForUserID:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)postBlockForUserID:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)postDestroyBlockForUserID:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)postMuteForUserID:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)postDestroyMuteForUserID:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)postSpamForUserID:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)getUser:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)getUsersFollowing:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor;
- (NSString *)getUsersFollowingMe:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor;
- (NSString *)getFollowingIDs:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor;
- (NSString *)getFollowingMeIDs:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor;
- (NSString *)getUserIDsForPendingRequestToMeWithCursor:(long long)cursor;
- (NSString *)getUserIDsForPendingRequestToProtectedAccountWithCursor:(long long)cursor;
- (NSString *)getRelationshipsOfMyAccountsWith:(NSArray *)userIDs;
- (NSString *)getUsersLookupUserIDs:(NSArray *)userIDs;
- (NSString *)getSearchedUsersWithQuery:(NSString *)query page:(unsigned long)page;


- (NSString *)getListsOfUser:(unsigned long long)userID screenName:(NSString *)screenName;
- (NSString *)getListsOfOwnerShipWithUser:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor;
- (NSString *)getListsOfSubscriptionWithUser:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor;
- (NSString *)getBackListTimeline:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID max:(unsigned long long)maxID;
- (NSString *)getForwardListTimeline:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID since:(unsigned long long)sinceID;
- (NSString *)getListTimeline:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID since:(unsigned long long)sinceID max:(unsigned long long)maxID;
- (NSString *)getMembersOfList:(unsigned long long )listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID cursor:(long long)cursor;
- (NSString  *)postCreateList:(NSString *)name isPublic:(BOOL)isPublic description:(NSString *)description;
- (NSString *)postUpdateList:(unsigned long long)listID name:(NSString *)name slug:(NSString *)slug isPublic:(BOOL)isPublic description:(NSString *)description;
- (NSString *)postDestroyOwnList:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID;
- (NSString *)postSubscriveList:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID;
- (NSString *)postDestroySubscrivedList:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID;
- (NSString *)postCreateMemberOfList:(unsigned long long)listID slug:(NSString *)slug userID:(unsigned long long)userID screenName:(NSString *)screenName ownerScreenName:(NSString *)ownerName ownerID:(unsigned long long)ownerID;
- (NSString *)postDestroyMemberOfList:(unsigned long long)listID slug:(NSString *)slug userID:(unsigned long long)userID screenName:(NSString *)screenName ownerScreenName:(NSString *)ownerName ownerID:(unsigned long long)ownerID;
- (NSString *)getShowsMemberOfList:(unsigned long long)listID slug:(NSString *)slug userID:(unsigned long long)userID userScreenName:(NSString *)userScreenName ownerScreenName:(NSString *)ownerScreenName ownerID:(unsigned long long)ownerID;


- (NSString *)getDeliveredDirectMessagesSinceID:(unsigned long long)since maxID:(unsigned long long)max;
- (NSString *)getSentDirectMessagesSinceID:(unsigned long long)since maxID:(unsigned long long)max;
- (NSString *)postDestroyDirectMessagesRequireID:(unsigned long long)require;
- (NSString *)postDirectMessage:(NSString *)text screenName:(NSString *)screenName userID:(unsigned long long)userID;


- (NSString *)getReverseGeocode:(float)latitude longi:(float)longitude;

- (NSString *)getHelpConfiguration;

@end

//
//  MBTwitterAPICenter.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTwitterAPICenter.h"
#import "MBTweet.h"



#define COUNT_OF_STATUSES_TIMELINE 200
#define COUNT_OF_DIRECT_MESSAGES 50
#define COUNT_OF_USERS 50
#define COUNT_OF_OWNER_LISTS 40

@interface MBTwitterAPICenter() 

@end

@implementation MBTwitterAPICenter
#pragma mark -
#pragma mark Initialize
- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    _connections = [NSMutableDictionary dictionary];
}

#pragma mark -
#pragma mark Connecter
- (NSString *)sendRequestMethod:(NSString *)method resource:(NSString *)resource parameters:(NSDictionary *)parameters requestType:(MBRequestType)requestType responseType:(MBResponseType)responseType
{
    // リクエスト用にURLを整えたりパラメータをつけたりする
    // リクエストを作成
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] init];
    //OAMutableRequest なら、 [request prepare]
    
    MBTwitterAPIHTTPConnecter *connecter = [[MBTwitterAPIHTTPConnecter alloc] initWithRequest:mutableRequest requestType:requestType responseType:responseType];
    connecter.delegate = self;
    
    // for cancel
    NSString *connectionIdentifier = [connecter identifier];
    [self.connections setObject:[NSNumber numberWithBool:YES] forKey:connectionIdentifier];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [connecter start];
    });
    
    return connectionIdentifier;
}

- (void)failedConnecter:(MBTwitterAPIHTTPConnecter *)connecter error:(NSError *)error responseType:(MBResponseType)responseType
{
    
}

- (void)finishedConnecter:(MBTwitterAPIHTTPConnecter *)connecter data:(NSData *)data responseType:(MBResponseType)responseType
{
    if (NO == [self.connections objectForKey:[connecter identifier]] || nil == [self.connections objectForKey:[connecter identifier]]) {
        return;
    }
    
    [self parseJSONData:data responseType:responseType];
}

#pragma mark Parser
- (void)parseJSONData:(NSData *)jsonData responseType:(MBResponseType)responseType
{
    
    // パースも非同期で行う
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSError *error = nil;
        NSData *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        // パースが終わったら
        dispatch_async(dispatch_get_main_queue(), ^{
            if (MBTwitterStatuseResponse == responseType) {
                NSArray *tweets = [NSKeyedUnarchiver unarchiveObjectWithData:parsedData];
                for(NSDictionary *parsedDict in tweets) {
                    MBTweet *tweet = [[MBTweet alloc] initWithDictionary:parsedDict];
                    NSLog(@"tweet = %@", tweet.tweetText);
                }
            }
            // [mbtweetManager storeTweets:tweets]; つぶやきだったら、つぶやきオブジェクトを保存。
            // [_delegate sendFinishingSpecifiedHandle] つぶやきだったらつぶやきIDセットをコントローラに送って、更新させる。
        });
    });
}

#pragma mark -
#pragma mark API Methods
#pragma mark Home Timeline
- (NSString *)getBackHomeTimeLineMaxID:(unsigned long long)max
{
    return [self getHomeTimeLineSinceID:0 maxID:max];
}

- (NSString *)getForwardHomeTimeLineSinceID:(unsigned long long)since
{
    return [self getHomeTimeLineSinceID:since maxID:0];
}

- (NSString *)getHomeTimeLineSinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    NSInteger count = COUNT_OF_STATUSES_TIMELINE;
    if (since == 0 && max == 0) { // at firstTime
        count = 20;
    }
    return [self getHomeTimeLineSinceID:since maxID:max count:count];
}

- (NSString *)getHomeTimeLineSinceID:(unsigned long long)since maxID:(unsigned long long)max count:(NSInteger)count
{
    NSString *resource = [NSString stringWithFormat:@"statuses/home_timeline"];
    return [self getTimelineSince:since max:max count:count resource:resource];
}

- (NSString *)getTimelineSince:(unsigned long long)since max:(unsigned long long)max count:(NSInteger)count resource:(NSString *)resource
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (since > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", since] forKey:@"since_id"];
    }
    if (max > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", max] forKey:@"max_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"count"];
    }
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterHomeTimelineRequest responseType:MBTwitterStatusesResponse];
}

#pragma mark Reply Timeline
- (NSString *)getBackReplyTimelineMaxID:(unsigned long long)max
{
    return [self getReplyTimelineSinceID:0 maxID:max];
}

- (NSString *)getForwardReplyTimelineSinceID:(unsigned long long)since
{
    return [self getReplyTimelineSinceID:since maxID:0];
}

- (NSString *)getReplyTimelineSinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    NSInteger count = COUNT_OF_STATUSES_TIMELINE;
    if (since == 0 && max == 0) { // at firstTime
        count = 20;
    }
    return [self getReplyTimelineSinceID:since maxID:max count:count];
}

- (NSString *)getReplyTimelineSinceID:(unsigned long long)since maxID:(unsigned long long)max count:(NSInteger)count
{
    NSString *resource = @"statuses/mentions_timeline";
    return [self getTimelineSince:since max:max count:count resource:resource];
}

#pragma mark User Timeline
- (NSString *)getBackUserTimelineUserID:(unsigned long long)userID screenName:(NSString *)screenName maxID:(unsigned long long)max
{
    return [self getUserTimelineUserID:userID screenName:screenName sinceID:0 maxID:max];
}

- (NSString *)getForwardUserTimelineUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since
{
    return [self getUserTimelineUserID:userID screenName:screenName sinceID:since maxID:0];
}

- (NSString *)getUserTimelineUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    NSInteger count = COUNT_OF_STATUSES_TIMELINE;
    if (since == 0 && max == 0) { // at firstTime
        count = 20;
    }
    return [self getUserTimelineUserID:userID screenName:screenName sinceID:since maxID:max count:count];
}

- (NSString *)getUserTimelineUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since maxID:(unsigned long long)max count:(NSInteger)count
{
    NSString *resource = @"statuses/user_timeline";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && nil == screenName) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    
    if (0 < since) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", since] forKey:@"since_id"];
    }
    
    if (0 < max) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", max] forKey:@"max_id"];
    }
    
    if (0 < count) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"count"];
    }
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterUserTimelineRequest responseType:MBTwitterStatusesResponse];
}

#pragma mark Tweet
- (NSString *)getTweet:(unsigned long long)requireID
{
    NSString *resource = [NSString stringWithFormat:@"statuses/show"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 < requireID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", requireID] forKey:@"id"];
        [parameters setObject:@"true" forKey:@"include_my_retweet"];
    } else {
        return nil;
    }
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesShowSingleTweetRequest responseType:MBTwitterStatuseResponse];
}

- (NSString *)postTweet:(NSString *)tweetText
{
    NSString *resource = [NSString stringWithFormat:@"statuses/update"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    NSInteger tweetLength = [tweetText length];
    
    if (nil != tweetText && tweetLength >=1 && tweetLength <= 140 ) {
        [parameters setObject:tweetText forKey:@"status"];
    } else {
        return nil;
    }

    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesUpdateRequest responseType:MBTwitterStatusesResponse];
}

- (NSString *)postTweet:(NSString *)tweetText withMedia:(NSArray *)mediaImages
{
    NSString *resource = [NSString stringWithFormat:@"statuses/update_with_media"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    NSInteger tweetLength = [tweetText length];
    if (nil != tweetText && tweetLength >=1 && tweetLength <= 140 ) {
        [parameters setObject:tweetText forKey:@"status"];
        for (UIImage *image in mediaImages) {
            NSData *imageData = UIImagePNGRepresentation(image);
            NSData *data64 = [imageData base64EncodedDataWithOptions:0];
            [parameters setObject:data64 forKey:@"media[]"];
        }
    } else {
        return nil;
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesUpdateRequest responseType:MBTwitterStatusesResponse];
}

- (NSString *)postTweet:(NSString *)tweetText inReplyTo:(NSArray *)acountIDs place:(NSDictionary *)place media:(NSArray *)media
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (nil != tweetText && tweetText.length >= 1 && tweetText.length <= 140) {
        [parameters setObject:tweetText forKey:@"status"];
    } else {
        return nil;
    }
    
    // Reply
    for (NSNumber *idNumber in acountIDs) {
        unsigned long long iduul = [idNumber unsignedLongLongValue];
        [parameters setObject:[NSString stringWithFormat:@"%llu", iduul] forKey:@"in_reply_to_status_id"];
    }
    
    // Place
    NSDictionary *placeDict = [place dictionaryForKey:@"place"];
    if (nil != placeDict) {
        NSString *latitudeStr = [placeDict stringForKey:@"lati"];
        if (nil != latitudeStr) {
            [parameters setObject:latitudeStr forKey:@"lat"];
        }
        
        NSString *longitudeStr = [placeDict stringForKey:@"longi"];
        if (nil != longitudeStr) {
            [parameters setObject:longitudeStr forKey:@"long"];
        }
        
        NSString *placeID = [placeDict stringForKey:@"placeID"];
        if (nil != placeID) {
            [parameters setObject:placeID forKey:@"place_id"];
        }
    }
    
    NSString *resource;
    
    // Photo Media
    if (0 < [media count]) {
        resource = [NSString stringWithFormat:@"statuses/update_with_media"];
        /*UIImage *mediaImage = [media firstObject];
        NSData *imageData = UIImagePNGRepresentation(mediaImage);
        NSData *data64 = [imageData base64EncodedDataWithOptions:0];*/
        NSData *data64 = [media firstObject];
        [parameters setObject:data64 forKey:@"media[]"];
        
    } else {
        resource = [NSString stringWithFormat:@"statuses/update"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesUpdateRequest responseType:MBTwitterStatuseResponse];
}

- (NSString *)postDestroyTweetForTweetID:(unsigned long long)tweetID
{
    NSString *resource = [NSString stringWithFormat:@"statuses/destroy/%llu", tweetID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == tweetID) {
        return nil;
    }
    
    if (0 < tweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", tweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesDestroyTweetRequest responseType:MBTwitterStatuseResponse];
}

- (NSString *)postRetweetForTweetID:(unsigned long long)retweetID
{
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweet/%llu", retweetID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == retweetID) {
        return nil;
    }
    
    if (0 < retweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", retweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesRetweetsOfTweetRequest responseType:MBTwitterStatuseResponse];
}


#pragma mark Favorite
- (NSString *)getBackFavoritesForUserID:(unsigned long long)userID screenName:(NSString *)screenName maxID:(unsigned long long)max
{
    return [self getFavoritesForUserID:userID screenName:screenName sinceID:0 maxID:max];
}

- (NSString *)getForwardFavoritesForUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since
{
    return [self getFavoritesForUserID:userID screenName:screenName sinceID:since maxID:0];
}

- (NSString *)getFavoritesForUserID:(unsigned long long)userID screenName:(NSString *)screenName sinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    NSString *resource = @"favorites/list";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && 0 == screenName.length) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    if (0 < since) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", since] forKey:@"since_id"];
    }
    if (0 < max) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", max] forKey:@"max_id"];
    }
    
    NSInteger count = COUNT_OF_STATUSES_TIMELINE;
    if (since == 0 && max == 0) { // at firstTime
        count = 20;
    }
    [parameters setObject:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"count"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterFavoritesListRequest responseType:MBTwitterStatusesResponse];
}

- (NSString *)postFavoriteForTweetID:(unsigned long long)favoriteTweetID
{
    NSString *resource = [NSString stringWithFormat:@"favorites/create"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 < favoriteTweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%lld", favoriteTweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFavoritesCreateRequest responseType:MBTwitterStatuseResponse];
}

- (NSString *)postDestroyFavoriteForTweetID:(unsigned long long)destroyTweetID
{
    NSString *resource = [NSString stringWithFormat:@"favorites/destroy"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 < destroyTweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", destroyTweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFavoritesDestroyRequest responseType:MBTwitterStatuseResponse];
}

#pragma mark User
- (NSString *)getUser:(unsigned long long)userID screenName:(NSString *)screenName
{
    NSString *resource = [NSString stringWithFormat:@"users/show"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && nil == screenName) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 < [screenName length]) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterUserRequest responseType:MBTwitterUserResponse];
}

- (NSString *)postFollowForUserID:(unsigned long long)userID screenName:(NSString *)screenName
{
    NSString *resource = [NSString stringWithFormat:@"friendships/create"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (0 == userID && nil == screenName) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (nil != screenName && screenName.length > 0) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFriendShipsCreateRequest responseType:MBTwitterUserResponse];
}

- (NSString *)postUnfollowForUserID:(unsigned long long)userID screenName:(NSString *)screenName
{
    NSString *resource = [NSString stringWithFormat:@"friendships/destroy"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (0 == userID && nil == screenName) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (nil != screenName && screenName.length > 0) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFriendShipsDestroyRequest responseType:MBTwitterUserResponse];
}

- (NSString *)getUsersFollowing:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor
{
    NSString *resource = @"friends/list";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && 0 == screenName.length) {
        return nil;
    }
    if (0 == cursor) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 == screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    if (0 != cursor) {
        [parameters setObject:[NSString stringWithFormat:@"%lld", cursor] forKey:@"cursor"];
    }
    [parameters setObject:[NSString stringWithFormat:@"%d", COUNT_OF_USERS] forKey:@"count"];
    [parameters setObject:@"true" forKey:@"skip_status"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterFriendsRequest responseType:MBTwitterUsersResponse];
}

- (NSString *)getUsersFollowingMe:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor
{
    NSString *resource = @"followers/list";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && 0 == screenName.length) {
        return nil;
    }
    if (0 == cursor) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    if (0 != cursor) {
        [parameters setObject:[NSString stringWithFormat:@"%lld", cursor] forKey:@"cursor"];
    }
    [parameters setObject:[NSString stringWithFormat:@"%d", COUNT_OF_USERS] forKey:@"count"];
    [parameters setObject:@"true" forKey:@"skip_status"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterFriendsRequest responseType:MBTwitterUsersResponse];
}

#pragma mark List
- (NSString *)getListsOfUser:(unsigned long long)userID screenName:(NSString *)screenName
{
    NSString *resource = @"lists/list";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && 0 == screenName.length ) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    
    [parameters setObject:@"true" forKey:@"reverse"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterListsListRequest responseType:MBTwitterListsResponse];
    
}

- (NSString *)getListsOfOwnerShipWithUser:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor
{
    NSString *resource = @"lists/ownerships";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && 0 == screenName.length) {
        return nil;
    }
    if (0 == cursor) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    if (0 != cursor) {
        [parameters setObject:[NSString stringWithFormat:@"%lld", cursor] forKey:@"cursor"];
    }
    [parameters setObject:[NSString stringWithFormat:@"%d", COUNT_OF_OWNER_LISTS] forKey:@"count"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterListsOwnerShipsRequest responseType:MBTwitterListsResponse];
    
}

- (NSString *)getListsOfSubscriptionWithUser:(unsigned long long)userID screenName:(NSString *)screenName cursor:(long long)cursor
{
    NSString *resource = @"lists/subscriptions";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == userID && 0 == screenName.length) {
        return nil;
    }
    if (0 == cursor) {
        return nil;
    }
    
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    if (0 != cursor) {
        [parameters setObject:[NSString stringWithFormat:@"%lld", cursor] forKey:@"cursor"];
    }
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterListsSubscriptionRequest responseType:MBTwitterListsResponse];
}

- (NSString *)getBackListTimeline:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID max:(unsigned long long)maxID
{
    return [self getListTimeline:listID slug:slug ownerScreenName:screenName ownerID:ownerID since:0 max:maxID];
}

- (NSString *)getForwardListTimeline:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID since:(unsigned long long)sinceID
{
    return [self getListTimeline:listID slug:slug ownerScreenName:screenName ownerID:ownerID since:sinceID max:0];
}

- (NSString *)getListTimeline:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID since:(unsigned long long)sinceID max:(unsigned long long)maxID
{
    NSString *resource = @"lists/statuses";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == listID && 0 == slug.length) {
        return nil;
    }
    
    if (0 < listID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", listID] forKey:@"list_id"];
    }
    if (0 < slug.length) {
        [parameters setObject:slug forKey:@"slug"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"owner_screen_name"];
    }
    if (0 < ownerID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", ownerID] forKey:@"owner_id"];
    }
    if (0 < sinceID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", sinceID] forKey:@"since_id"];
    }
    if (0 < maxID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", maxID] forKey:@"max_id"];
    }
    
    NSInteger count = COUNT_OF_STATUSES_TIMELINE;
    if (sinceID == 0 && maxID == 0) {
        count = 20;
    }
    [parameters setObject:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"count"];
    [parameters setObject:@"true" forKey:@"include_rts"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterListsStatusesRequest responseType:MBTwitterStatusesResponse];
}

- (NSString *)getMembersOfList:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID cursor:(long long)cursor
{
    NSString *resource = @"lists/members";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == listID && 0 == slug.length) {
        return nil;
    }
    if (0 == cursor) {
        return nil;
    }
    
    if (0 < listID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", listID] forKey:@"list_id"];
    }
    if (0 < slug.length) {
        [parameters setObject:slug forKey:@"slug"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"owner_screen_name"];
    }
    if (0 < ownerID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", ownerID] forKey:@"owner_id"];
    }
    
    if (0 != cursor) { // if do not provid, the one  = -1, if 0
        [parameters setObject:[NSString stringWithFormat:@"%lld", cursor] forKey:@"cursor"];
    }
    
    [parameters setObject:@"true" forKey:@"skip_status"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterListsMembersRequest responseType:MBTwitterUsersResponse];
    
}

- (NSString *)postCreateList:(NSString *)name isPublic:(BOOL)isPublic description:(NSString *)description
{
    NSString *resource = @"lists/create";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (nil == name || 0 == name.length) {
        return nil;
    }
    
    [parameters setObject:name forKey:@"name"];
    if (!isPublic) {
        [parameters setObject:@"private" forKey:@"mode"]; // specified no mode will be public
    } else {
        [parameters setObject:@"public" forKey:@"mode"];
    }
    
    if (0 < description.length) {
        [parameters setObject:description forKey:@"description"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterListsCreateRequest responseType:MBTwitterListResponse];
    
}

- (NSString *)postUpdateList:(unsigned long long)listID name:(NSString *)name slug:(NSString *)slug isPublic:(BOOL)isPublic description:(NSString *)description
{
    NSString *resource = @"lists/update";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == listID && 0 == slug.length) {
        return nil;
    }
    
    [parameters setObject:[NSString stringWithFormat:@"%llu", listID] forKey:@"list_id"];
    if (0 < slug.length) {
        [parameters setObject:slug forKey:@"slug"];
    }
    if (name) {
        [parameters setObject:name forKey:@"name"];
    }
    if (!isPublic) {
        [parameters setObject:@"private" forKey:@"mode"]; // specified no mode will be public
    } else {
        [parameters setObject:@"public" forKey:@"mode"];
    }
    if (description) {
        [parameters setObject:parameters forKey:@"description"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterListsUpdateRequest responseType:MBTwitterListResponse];
}

- (NSString *)postDestroyOwnList:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID
{
    NSString *resource = @"lists/destroy";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == listID) {
        if (0 == slug.length & nil == slug) {
            return nil;
        } else {
            if (0 == screenName.length & nil == screenName && 0 == ownerID) {
                return nil;
            }
        }
    }
    
    if (0 < listID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", listID] forKey:@"list_id"];
    }
    if (0 < slug.length) {
        [parameters setObject:slug forKey:@"slug"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"owner_screen_name"];
    }
    if (0 < ownerID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu",ownerID] forKey:@"owner_id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterListsDestroyRequest responseType:MBTwitterListResponse];
}

- (NSString *)postSubscriveList:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID
{
    NSString *resource = @"lists/subscribers/create";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == listID) {
        if (0 == slug.length & nil == slug) {
            return nil;
        } else {
            if (0 == screenName.length & nil == screenName && 0 == ownerID) {
                return nil;
            }
        }
    }
    
    if (0 < listID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", listID] forKey:@"list_id"];
    }
    if (0 < slug.length) {
        [parameters setObject:slug forKey:@"slug"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"owner_screen_name"];
    }
    if (0 < ownerID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu",ownerID] forKey:@"owner_id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterListsSubscriptionRequest responseType:MBTwitterListResponse];
}

- (NSString *)postDestroySubscrivedList:(unsigned long long)listID slug:(NSString *)slug ownerScreenName:(NSString *)screenName ownerID:(unsigned long long)ownerID
{
    NSString *resource = @"lists/subscribers/destroy";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == listID) {
        if (0 == slug.length & nil == slug) {
            return nil;
        } else {
            if (0 == screenName.length & nil == screenName && 0 == ownerID) {
                return nil;
            }
        }
    }
    
    if (0 < listID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", listID] forKey:@"list_id"];
    }
    if (0 < slug.length) {
        [parameters setObject:slug forKey:@"slug"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"owner_screen_name"];
    }
    if (0 < ownerID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu",ownerID] forKey:@"owner_id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterListsSubscriptionRequest responseType:MBTwitterListResponse];
}

- (NSString *)postDestroyMemberOfList:(unsigned long long)listID slug:(NSString *)slug userID:(unsigned long long)userID screenName:(NSString *)screenName ownerScreenName:(NSString *)ownerName ownerID:(unsigned long long)ownerID
{
    NSString *resource = @"lists/members/destroy";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == listID) {
        if (0 == slug.length & nil == slug) {
            return nil;
        } else {
            if (0 == screenName.length & nil == screenName && 0 == ownerID) {
                return nil;
            }
        }
    }
    
    if (0 < listID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", listID] forKey:@"list_id"];
    }
    if (0 < slug.length) {
        [parameters setObject:slug forKey:@"slug"];
    }
    if (0 < userID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    if (0 < screenName.length) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    if (0 < ownerName) {
        [parameters setObject:ownerName forKey:@"owner_screen_name"];
    }
    if (0 < ownerID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", ownerID] forKey:@"owner_id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterListsMembersDestroyRequest responseType:MBTwitterUserResponse];
    
}

#pragma mark Direct Messages
- (NSString *)getDeliveredDirectMessagesSinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    NSString *resource = [NSString stringWithFormat:@"direct_messages"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (0 < since) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", since] forKey:@"since_id"];
    }
    if (0 < max) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", max] forKey:@"max_id"];
    }
    
    [parameters setObject:[NSString stringWithFormat:@"%d", COUNT_OF_DIRECT_MESSAGES] forKey:@"count"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterDirectMessagesRequest responseType:MBTwitterDirectMessagesResponse];
}

- (NSString *)getSentDirectMessagesSinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    NSString *resource = [NSString stringWithFormat:@"direct_messages/sent"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (0 < since) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", since] forKey:@"since_id"];
    }
    if (0 < max) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", max] forKey:@"max_id"];
    }
    
    [parameters setObject:[NSString stringWithFormat:@"%d", COUNT_OF_DIRECT_MESSAGES] forKey:@"count"];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterDirectMessagesSentRequest responseType:MBTwitterDirectMessagesResponse];
}

- (NSString *)postDestroyDirectMessagesRequireID:(unsigned long long)require
{
    NSString *resource = [NSString stringWithFormat:@"direct_messages/destroy"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 == require) {
        return nil;
    }
    NSLog(@"require = %llu", require);
    [parameters setObject:[NSString stringWithFormat:@"%llu", require] forKey:@"id"];
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterDirectMessagesDestroyRequest responseType:MBTwitterDirectMessageResponse];
}

- (NSString *)postDirectMessage:(NSString *)text screenName:(NSString *)screenName userID:(unsigned long long)userID
{
    NSString *resource = [NSString stringWithFormat:@"direct_messages/new"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    NSInteger textLength = [text length];
    if (0 == userID && nil == screenName) {
        return nil;
    }
    if (nil == text) {
        return nil;
    }
    if (nil != text && textLength > 0 && textLength <= 140) {
        [parameters setObject:text forKey:@"text"];
    }
    
    if (screenName && screenName.length > 0) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    if (userID > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", userID] forKey:@"user_id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterDirectMessagesNewRequest responseType:MBTwitterDirectMessageResponse];
}

#pragma mark Geo
- (NSString *)getReverseGeocode:(float)latitude longi:(float)longitude
{
    NSString *resource = @"geo/reverse_geocode";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];

    if (0 < latitude) {
        [parameters setObject:[NSString stringWithFormat:@"%6f", latitude] forKey:@"lat"];
    }
    if (0 < longitude) {
        [parameters setObject:[NSString stringWithFormat:@"%6f", longitude] forKey:@"long"];
    }
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterGeoReverseGeoCodeRequest responseType:MBTwitterGeocodeResponse];
}

#pragma mark Help
- (NSString *)getHelpConfiguration
{
    NSString *resource = [NSString stringWithFormat:@"help/configuration"];
    NSDictionary *parameters = [NSDictionary dictionary];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterHelpConfigurationRequest responseType:MBTwitterHelpResponse];
}

@end

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
            if (MBTwitterStatuse == responseType) {
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
#pragma mark Get Twitter API Methods
- (NSString *)getBackHomeTimeLineMaxID:(unsigned long long)max
{
    return [self getHomeTimeLineSinceID:0 maxID:max];
}

- (NSString *)getForwardHomeTimeLineSinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    return [self getHomeTimeLineSinceID:since maxID:max];
}

- (NSString *)getHomeTimeLineSinceID:(unsigned long long)since maxID:(unsigned long long)max
{
    return [self getHomeTimeLineSinceID:since maxID:max count:COUNT_OF_STATUSES_TIMELINE];
}

- (NSString *)getHomeTimeLineSinceID:(unsigned long long)since maxID:(unsigned long long)max count:(int)count
{
    NSString *resource = [NSString stringWithFormat:@"statuses/home_timeline"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (since > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", since] forKey:@"since_id"];
    }
    if (max > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", max] forKey:@"max_id"];
    }
    if (count > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }

    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterHomeTimelineRequest responseType:MBTwitterStatuses];
}

#pragma mark Post Twitter API Methods
- (NSString *)postTweet:(NSString *)tweetText
{
    NSString *resource = [NSString stringWithFormat:@"statuses/update"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    NSInteger tweetLength = [tweetText length];
    if (nil != tweetText && tweetLength >=1 && tweetLength <= 140 ) {
        [parameters setObject:tweetText forKey:@"status"];
    }

    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesUpdateRequest responseType:MBTwitterStatuses];
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
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesUpdateRequest responseType:MBTwitterStatuses];
}

- (NSString *)postTweet:(NSString *)tweetText inReplyTo:(NSArray *)acountIDs place:(NSDictionary *)place media:(NSArray *)media
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (nil == tweetText && 1 > tweetText.length && 140 < tweetText.length) {
        return nil;
    }
    [parameters setObject:tweetText forKey:@"status"];
    
    // Reply
    for (NSNumber *idNumber in acountIDs) {
        unsigned long long iduul = [idNumber unsignedLongLongValue];
        [parameters setObject:[NSString stringWithFormat:@"%llu", iduul] forKey:@"in_reply_to_status_id"];
    }
    
    // Place
    NSDictionary *placeDict = [place dictionaryForKey:@"place"];
    if (nil != placeDict) {
        NSNumber *latitudeNumber = [placeDict numberForKey:@"lat"];
        if (nil != latitudeNumber) {
            long lati = [latitudeNumber longValue];
            [parameters setObject:[NSString stringWithFormat:@"%ld", lati] forKey:@"lat"];
        }
        
        NSNumber *longitudeNumber = [placeDict numberForKey:@"longi"];
        if (nil != longitudeNumber) {
            long longi = [longitudeNumber longValue];
            [parameters setObject:[NSString stringWithFormat:@"%ld", longi] forKey:@"long"];
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
        UIImage *mediaImage = [media firstObject];
        NSData *imageData = UIImagePNGRepresentation(mediaImage);
        NSData *data64 = [imageData base64EncodedDataWithOptions:0];
        [parameters setObject:data64 forKey:@"media[]"];
        
    } else {
        resource = [NSString stringWithFormat:@"statuses/update"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesUpdateRequest responseType:MBTwitterStatuses];
}

- (NSString *)postDestroyTweetForTweetID:(unsigned long long)tweetID
{
    NSString *resource = [NSString stringWithFormat:@"statuses/destroy/%llu", tweetID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 < tweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", tweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesDestroyTweetRequest responseType:MBTwitterStatuses];
}

- (NSString *)postRetweetForTweetID:(unsigned long long)retweetID
{
    
    NSString *resource = [NSString stringWithFormat:@"statuses/retweet/%llu", retweetID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 < retweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", retweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterStatusesRetweetsOfTweetRequest responseType:MBTwitterStatuses];
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
    if (nil != screenName) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFriendShipsCreateRequest responseType:MBTwitterStatuses];
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
    if (nil != screenName) {
        [parameters setObject:screenName forKey:@"screen_name"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFriendShipsDestroyRequest responseType:MBTwitterStatuses];
}

- (NSString *)postFavoriteForTweetID:(unsigned long long)favoriteTweetID
{
    NSString *resource = [NSString stringWithFormat:@"favorites/create"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 < favoriteTweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%lld", favoriteTweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFavoritesCreateRequest responseType:MBTwitterStatuses];
}

- (NSString *)postDestroyFavoriteForTweetID:(unsigned long long)destroyTweetID
{
    NSString *resource = [NSString stringWithFormat:@"favorites/destroy"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    if (0 < destroyTweetID) {
        [parameters setObject:[NSString stringWithFormat:@"%llu", destroyTweetID] forKey:@"id"];
    }
    
    return [self sendRequestMethod:HTTP_POST_METHOD resource:resource parameters:parameters requestType:MBTwitterFavoritesDestroyRequest responseType:MBTwitterStatuses];
}

- (NSString *)getHelpConfiguration
{
    NSString *resource = [NSString stringWithFormat:@"help/configuration"];
    NSDictionary *parameters = [NSDictionary dictionary];
    
    return [self sendRequestMethod:HTTP_GET_METHOD resource:resource parameters:parameters requestType:MBTwitterHelpConfigurationRequest responseType:MBTwitterHelp];
}

@end

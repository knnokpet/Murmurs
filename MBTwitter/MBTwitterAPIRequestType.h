//
//  MBTwitterAPIRequestType.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MBTwitterAPIRequestType {
    MBTwitterHomeTimelineRequest = 0,                   // my account latest statuses
    MBTwitterUserTimelineRequest,                       // specified user's latest statuses
    MBTwitterMentionsTimelineRequest,                   // my account latest mentions
    MBTwitterRetweetsOfMeRequest,                       // my account latest Retweets
    MBTwitterStatusesRetweetsOfTweetRequest,            // specified tweet's latest retweets
    MBTwitterStatusesShowSingleTweetRequest,            // show specified tweet
    MBTwitterStatusesDestroyTweetRequest,               // destroy specified tweet
    MBTwitterStatusesUpdateRequest,                     // post tweet
    MBTwitterStatusesOriginalTweetOfRetweetRequest,     // get original tweet of Retweet
    MBTwitterStatusesUpdateWithMediaRequest,            // post tweet with media
    MBTwitterStatusesOEmbedRequest,                     // 謎
    MBTwitterStatusesRetweetersOfTweetRequest,          // get users who Retweet specified tweet
    MBTwitterSearchTweetsRequest,                       // search tweet
    MBTwitterStatusesFilterRequest,                     // get public statuses that much filter predicate. POST & GET
    MBTwitterStatusesSampleRequest,                     // get small random sample public statuses
    MBTwitterUserRequest,                               // streams messages for single user
    MBTwitterSiteRequest,                               // streams messages for a set of users
    MBTwitterDirectMessagesRequest,                     // get my account's latest direct messages
    MBTwitterDirectMessagesSentRequest,                 // get my account's latest sent direct messages
    MBTwitterDirectMessagesShowRequest,                 // get my account's specified single direct message
    MBTwitterDirectMessagesDestroyRequest,              // delete specified direct message
    MBTwitterDirectMessagesNewRequest,                  // post new direct message
    MBTwitterFriendShipsNoRetweetsRequest,              // get users that my account does not want to receive retweets
    MBTwitterFriendsRequest,                            // follow
    MBTwitterFollowersRequest,                          // follower
    MBTwitterFriendShipsInComingRequest,                // pending follow request, my account is received
    MBTwitterFriendShipsOutGoingRequest,                // pending follow request , my account sent to protected user
    MBTwitterFriendShipsCreateRequest,                  // request when success, allows my account to follow
    MBTwitterFriendShipsDestroyRequest,                 // unfollow
    MBTwitterFriendShipsUpdateRequest,                  // allowing enable/disable retweet & device notification from specified user
    MBTwitterFriendShipsShowRequest,                    //
    MBTwitterFriendsListRequest,
    MBTwitterFollowersListRequest,
    MBTwitterFriendShipsLookUpRequest,
    MBTwitterAccountSettingRequest,
    MBTwitterAccountVerifyCredentialsRequest,
    MBTwitterAccountUpdateDeliveryDeviceRequest,
    MBTwitterAccountUpdateProfileRequest,
    MBTwitterAccountUpdateProfileBackgroundImageRequest,
    MBTwitterAccountUpdateProfileColorsRequest,
    MBTwitterAccountUpdateProfileImageRequest,
    MBTwitterBlocksListRequest,
    MBTwitterBlocksRequest,
    MBTwitterBlocksCreateRequest,
    MBTwitterBlocksDestroyRequest,
    MBTwitterMuteCreaterequest,
    MBTwitterMuteDestroyRequest,
    MBTwitterMuteUserIDsRequest,
    MBTwitterMuteUsersRequest,
    MBTwitterUserLookUpRequest,
    MBTwitterUsersShowRequest,
    MBTwitterUsersSearchRequest,
    MBTwitterUsersContributeesRequest,
    MBTwitterUsersContributorsRequest,
    MBTwitterAccountRemoveProfileBannerRequest,
    MBTwitterAccountUpdateProfileBannerRequest,
    MBTwitterUsersProfileBannerRequest,
    MBTwitterUsersSuggestionsSlugRequest,
    MBTwitterUsersSuggestionsRequest,
    MBTwitterUsersSuggestionsSlugMembersRequest,
    MBTwitterFavoritesListRequest,
    MBTwitterFavoritesDestroyRequest,
    MBTwitterFavoritesCreateRequest,
    MBTwitterListsListRequest,
    MBTwitterListsStatusesRequest,
    MBTwitterListsMembersDestroyRequest,
    MBTwitterListsMemberShipsRequest,
    MBTwitterListsSubscribersRequest,
    MBTwitterListsSubscribersCreateRequest,
    MBTwitterListsSubscribersShowRequest,
    MBTwitterListsSubscribersDestroyRequest,
    MBTwitterListsMembersCreateAllRequest,
    MBTwitterListsMembersShowRequest,
    MBTwitterListsMembersRequest,
    MBTwitterListsMembersCreateRequest,
    MBTwitterListsDestroyRequest,
    MBTwitterListsUpdateRequest,
    MBTwitterListsCreateRequest,
    MBTwitterListsShowRequest,
    MBTwitterListsSubscriptionRequest,
    MBTwitterListsMembersDestroyAllRequest,
    MBTwitterListsOwnerShipsRequest,
    MBTwitterSavedSearchesListRequest,
    MBTwitterSavedSearchesShowRequest,
    MBTwitterSavedSearchesCreateRequest,
    MBTwitterSavedSearchesDestroyRequest,
    MBTwitterGeoPlaceRequest,
    MBTwitterGeoReverseGeoCodeRequest,
    MBTwitterGeoSearchRequest,
    MBTwitterGeoSimilarPlacesRequest,
    MBTwitterTrendsPlaceRequest,
    MBTwitterTrendsAvailableRequest,
    MBTwitterTrendsClosestRequest,
    MBTwitterUsersReportSpamRequest,
    MBTwitterHelpConfigurationRequest,
} MBRequestType;

typedef enum MBResponseType {
    MBTwitterStatusesResponse = 0,
    MBTwitterStatuseResponse = 1,
    MBTwitterSearchedStatusesResponse,
    MBTwitterDestroyStatusResponse,
    MBTwitterUsersResponse,
    MBTwitterUserResponse,
    MBTwitterUsersLookUpResponse,
    MBTwitterUserIDsResponse,
    MBTwitterUserRelationshipsResponse,
    MBTwitterListResponse,
    MBTwitterListsResponse,
    MBTwitterDirectMessagesResponse,
    MBTwitterDirectMessageResponse,
    MBTwitterGeocodeResponse,
    MBTwitterHelpResponse,
} MBResponseType;

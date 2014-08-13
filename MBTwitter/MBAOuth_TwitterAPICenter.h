//
//  MBAOuth_TwitterAPICenter.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTwitterAPICenter.h"

@protocol MBAOuth_TwitterAPICenterDelegate;
@interface MBAOuth_TwitterAPICenter : MBTwitterAPICenter

@property (nonatomic, weak) id <MBAOuth_TwitterAPICenterDelegate> delegate;

@end



@protocol MBAOuth_TwitterAPICenterDelegate <NSObject>

@optional
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedTweets:(NSArray *)tweets;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center requestType:(MBRequestType)requestType parsedUsers:(NSArray *)users;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUsers:(NSArray *)users next:(NSNumber *)next previous:(NSNumber *)previous;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedUserIDs:(NSArray *)userIDs next:(NSNumber *)next previous:(NSNumber *)previous;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center relationships:(NSArray *)relationships;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedLists:(NSArray *)lists;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedLists:(NSArray *)lists next:(NSNumber *)next previous:(NSNumber *)previous;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedDirectMessages:(NSArray *)messages;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center parsedPlaces:(NSArray *)places;

- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center maxMedias:(NSNumber *)medias photoSizeLimit:(NSNumber *)photoSizeLimit shortURLLength:(NSNumber *)number;
- (void)twitterAPICenter:(MBAOuth_TwitterAPICenter *)center error:(NSError *)error;

@end
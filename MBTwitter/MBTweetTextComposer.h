//
//  MBTweetTextComposer.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBTweet;
@class MBUser;
@interface MBTweetTextComposer : NSObject
/* font の magicNumber は解消しなきゃ */
+ (NSAttributedString *)attributedStringForTweet:(MBTweet *)tweet;
+ (NSAttributedString *)attributedStringForTweet:(MBTweet *)tweet tintColor:(UIColor *)tintColor;
+ (NSAttributedString *)attributedStringForUser:(MBUser *)user linkColor:(UIColor *)linkColor;
+ (NSAttributedString *)attributedStringForTimelineUser:(MBUser *)user charFont:(UIFont *)charaFont screenFont:(UIFont *)screenFont;
+ (NSAttributedString *)attributedStringForTimelineDate:(NSString *)dateString font:(UIFont *)font screeName:(NSString *)screenName tweetID:(unsigned long long)tweetID;
+ (NSAttributedString *)attributedStringForDetailTweetDate:(NSString *)dateString font:(UIFont *)font screeName:(NSString *)screenName tweetID:(unsigned long long)tweetID;

@end

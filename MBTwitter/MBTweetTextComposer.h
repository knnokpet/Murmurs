//
//  MBTweetTextComposer.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBTweet;
@interface MBTweetTextComposer : NSObject

+ (NSAttributedString *)attributedStringForTweet:(MBTweet *)tweet;
+ (NSAttributedString *)attributedStringForTweet:(MBTweet *)tweet tintColor:(UIColor *)tintColor;

@end

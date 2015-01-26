//
//  MBTextCacher.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/25.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBTextCacher : NSObject

+ (MBTextCacher *)sharedInstance;

- (NSAttributedString *)cachedUserNameWithUserIDStr:(NSString *)key;
- (NSAttributedString *)cachedTweetTextWithTweetIDStr:(NSString *)key;
- (void)storeUserName:(NSAttributedString *)attriName key:(NSString *)key;
- (void)storeTweetText:(NSAttributedString *)attText key:(NSString *)key;

- (void)clearMemoryCache;

@end

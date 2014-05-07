//
//  MBDirectMessage.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweet.h"

#define KEY_RECIPIENT @"recipient"
#define KEY_SENDEER @"sender"

@interface MBDirectMessage : MBTweet

@property (nonatomic, readonly) MBUser *recipient;
@property (nonatomic, readonly) MBUser *sender;

@end

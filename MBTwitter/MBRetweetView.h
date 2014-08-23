//
//  MBRetweetView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBMentionUserLink;
@protocol MBRetweetViewDelegate;
@interface MBRetweetView : UIView

@property (nonatomic, weak) id <MBRetweetViewDelegate> delegate;

@property (nonatomic, readonly) NSAttributedString *retweeterString;
@property (nonatomic, readonly) MBMentionUserLink *userLink;
- (void)setRetweeterString:(NSAttributedString *)retweeterString;
- (void)setUserLink:(MBMentionUserLink *)userLink;

@end



@protocol MBRetweetViewDelegate <NSObject>

- (void)retweetView:(MBRetweetView *)retweetView userLink:(MBMentionUserLink *)userLink;

@end
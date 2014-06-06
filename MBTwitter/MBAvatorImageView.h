//
//  MBAvatorImageView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBAvatorImageViewDelegate;
@interface MBAvatorImageView : UIImageView

@property (nonatomic, weak) id <MBAvatorImageViewDelegate> delegate;
@property (nonatomic, readonly) NSNumber *userID;
@property (nonatomic, readonly) NSString *userIDStr;
- (void)setUserID:(NSNumber *)userID;
- (void)setUserIDStr:(NSString *)userIDStr;

@end



@protocol MBAvatorImageViewDelegate <NSObject>

- (void)imageViewDidClick:(MBAvatorImageView *)imageView userID:(NSNumber *)userID userIDStr:(NSString *)userIDStr;

@end
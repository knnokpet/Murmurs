//
//  MBImageChasher.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBImageChasher : NSObject

+ (MBImageChasher *)sharedInstance;

- (UIImage *)cachedProfileImageForUserID:(NSString *)userID;
- (UIImage *)cachedProfileImageForUserID:(NSString *)userID defaultImage:(UIImage *)defaultImage;
- (UIImage *)cachedMediaImageForMediaID:(NSString *)mediaID;

- (void)storeProfileImage:(UIImage *)image data:(NSData *)data forUserID:(NSString *)userID;
- (void)storeMediaImage:(UIImage *)image data:(NSData *)data  forMediaID:(NSString *)mediaID;

- (void)crearMemoryCache;
- (void)deleteAllCacheFiles;

@end

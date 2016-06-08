//
//  MBImageCacher.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBImageCacher : NSObject

+ (MBImageCacher *)sharedInstance;

- (UIImage *)cachedProfileImageForUserID:(NSString *)userID;
- (UIImage *)cachedProfileImageForUserID:(NSString *)userID defaultImage:(UIImage *)defaultImage;
- (void)storeProfileImage:(UIImage *)image data:(NSData *)data forUserID:(NSString *)userID;

- (UIImage *)cachedMediaImageForMediaID:(NSString *)mediaID;
- (UIImage *)cachedCroppedMediaImageForMediaID:(NSString *)mediaID;
- (void)storeMediaImage:(UIImage *)image data:(NSData *)data  forMediaID:(NSString *)mediaID;
- (void)storeCroppedMediaImage:(UIImage *)image forMediaID:(NSString *)mediaID;

- (UIImage *)cachedTimelineImageForUser:(NSString *)userID;
- (void)storeTimelineImage:(UIImage *)image forUserID:(NSString *)userID;

- (UIImage *)cachedUsersImageForUser:(NSString *)userID;
- (void)storeUsersImage:(UIImage *)image forUserID:(NSString *)userID;

- (UIImage *)cachedBannerImageForUserID:(NSString *)userID;
- (void)storeBannerImage:(UIImage *)image forUserID:(NSString *)userID;

- (BOOL)isDownloadingImageWithUrlStr:(NSString *)urlStr;
- (void)addUrlStrForDownloadingImage:(NSString *)urlStr;
- (void)removeUrlStrForDownloadingImage:(NSString *)urlStr;

- (void)clearMemoryCache;
- (void)deleteAllCacheFiles;

@end

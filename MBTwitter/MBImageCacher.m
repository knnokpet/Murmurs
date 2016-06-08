//
//  MBImageCacher.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBImageCacher.h"
#import <CommonCrypto/CommonHMAC.h>
#import "UIImage+Resize.h"

@interface MBImageCacher()

@property (nonatomic, readonly) NSFileManager *fileManager;
@property (nonatomic, readonly) NSString *cacheDirectory;
@property (nonatomic, readonly) NSString *profileImageDirectory;
@property (nonatomic, readonly) NSString *mediaImageDirectory;

@property (nonatomic, readonly) NSCache *profileImageCache;
@property (nonatomic, readonly) NSCache *timelineImageCache;
@property (nonatomic, readonly) NSCache *usersImageCache;
@property (nonatomic, readonly) NSCache *mediaImageCache;
@property (nonatomic, readonly) NSCache *croppedMediaImageCache;
@property (nonatomic, readonly) NSCache *bannerImageCache;

@property (nonatomic, readonly) NSMutableDictionary *urlStringsForDownloadingImage;

@end

@implementation MBImageCacher
#pragma mark -
#pragma mark Initialize
+ (MBImageCacher *)sharedInstance
{
    static MBImageCacher *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initSharedInstance];
    });
    
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cacheDirectory = [[paths lastObject] stringByAppendingPathComponent:@"images"];
        _profileImageDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"profile"];
        _mediaImageDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"media"];
        [self createDirectories];
        
        _profileImageCache = [[NSCache alloc] init];
        self.profileImageCache.countLimit = 100;
        _timelineImageCache = [[NSCache alloc] init];
        self.timelineImageCache.countLimit = 500;
        _usersImageCache = [[NSCache alloc] init];
        self.usersImageCache.countLimit = 1000;
        _mediaImageCache = [[NSCache alloc] init];
        self.mediaImageCache.countLimit = 50;
        _croppedMediaImageCache = [[NSCache alloc] init];
        self.croppedMediaImageCache.countLimit = 50;
        _bannerImageCache = [[NSCache alloc] init];
        self.bannerImageCache.countLimit = 30;
        
        _urlStringsForDownloadingImage = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -
#pragma mark Directory
- (NSString *)pathForID:(NSString *)sourceID directory:(NSString *)directoryPath
{
    NSString *key = [self keyForID:sourceID];
    NSString *path = [self pathForKey:key directory:directoryPath];
    
    return path;
}

- (NSString *)pathForKey:(NSString *)key directory:(NSString *)path
{
    NSString *directoryPath = [path stringByAppendingPathComponent:key];
    return directoryPath;
}

- (NSString *)keyForID:(NSString *)sourceID
{
    NSString *md5ID = [self MD5Digest:sourceID];
    NSString *key = [md5ID substringToIndex:2];
    
    return key;
}

- (NSString *)MD5Digest:(NSString *)source
{
    const char *str = [source UTF8String];
    unsigned char md5Result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), md5Result);
    NSMutableString *resultStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [resultStr appendFormat:@"%02x", md5Result[i]];
    }
    
    return resultStr;
}

- (void)createDirectories
{
    [self createDirectoryAtPath:self.cacheDirectory];
    [self createDirectoryAtPath:self.profileImageDirectory];
    [self createDirectoryAtPath:self.mediaImageDirectory];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        for (int j = 0; j < CC_MD5_DIGEST_LENGTH; j ++) {
            NSString *subProfileDirectoryPath = [NSString stringWithFormat:@"%@/%X%X", self.profileImageDirectory, i, j];
            NSString *subMediaDirectoryPath = [NSString stringWithFormat:@"%@/%X%X", self.mediaImageDirectory, i, j];
            [self createDirectoryAtPath:subProfileDirectoryPath];
            [self createDirectoryAtPath:subMediaDirectoryPath];
        }
    }
    
}

- (void)createDirectoryAtPath:(NSString *)path
{
    BOOL isDirectory = NO;
    BOOL exists = [self.fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!isDirectory || !exists) {
        [self.fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark -
#pragma mark Cached Image
- (UIImage *)cachedProfileImageForUserID:(NSString *)userID
{
    return [self cachedProfileImageForUserID:userID defaultImage:nil];
}

- (UIImage *)cachedProfileImageForUserID:(NSString *)userID defaultImage:(UIImage *)defaultImage
{
    return [self cachedProfileImageForID:userID defaultImage:defaultImage from:self.profileImageCache directory:self.profileImageDirectory];
}

- (UIImage *)cachedProfileImageForID:(NSString *)sourceID defaultImage:(UIImage *)defaultImage from:(NSCache *)cache directory:(NSString *)directoryPath
{
    if (sourceID == nil) {
        return defaultImage;
    }
    
    NSString *keyForID = sourceID;
    UIImage *cachedImage = [cache objectForKey:keyForID];
    if (cachedImage) {
        return cachedImage;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pathForImage = [self pathForID:keyForID directory:directoryPath];
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:pathForImage];
        UIImage *savedImage = [[UIImage alloc] initWithData:imageData];
        UIImage *resizedImage = [savedImage imageByScallingToFillSize:CGSizeMake(44.0f, 44.0f)];
        [self storeTimelineImage:resizedImage forUserID:sourceID];
    });
    
    return defaultImage;
}

- (UIImage *)cachedTimelineImageForUser:(NSString *)userID
{
    if (nil == userID) {
        return nil;
    }
    
    UIImage *cachedImage = [self.timelineImageCache objectForKey:userID];
    if (cachedImage) {
        return cachedImage;
    }
    return nil;
}

- (UIImage *)cachedUsersImageForUser:(NSString *)userID
{
    if (nil == userID) {
        return nil;
    }
    
    UIImage *cachedImage = [self.usersImageCache objectForKey:userID];
    if (cachedImage) {
        return cachedImage;
    }
    return nil;
}

- (UIImage *)cachedMediaImageForMediaID:(NSString *)mediaID
{
    if (!mediaID || mediaID.length == 0) {
        return nil;
    }
    UIImage *cachedImage = [self.mediaImageCache objectForKey:mediaID];
    if (cachedImage) {
        return cachedImage;
    }
    
    return nil;
}

- (UIImage *)cachedCroppedMediaImageForMediaID:(NSString *)mediaID
{
    if (!mediaID || mediaID.length == 0) {
        return nil;
    }
    UIImage *cachedImage = [self.croppedMediaImageCache objectForKey:mediaID];
    if (cachedImage) {
        return cachedImage;
    }
    
    return nil;
}

- (UIImage *)cachedBannerImageForUserID:(NSString *)userID
{
    if (!userID || userID.length == 0) {
        return nil;
    }
    UIImage *cachedImage = [self.bannerImageCache objectForKey:userID];
    if (cachedImage) {
        return cachedImage;
    }
    
    return nil;
}

#pragma mark Store Image

- (void)storeProfileImage:(UIImage *)image data:(NSData *)data forUserID:(NSString *)userID
{
    [self storeImage:image data:data forID:userID to:self.profileImageCache directory:self.profileImageDirectory];
}

- (void)storeMediaImage:(UIImage *)image data:(NSData *)data forMediaID:(NSString *)mediaID
{
    [self storeImage:image data:data forID:mediaID to:self.mediaImageCache directory:self.mediaImageDirectory];
}

- (void)storeImage:(UIImage *)image data:(NSData *)data forID:(NSString *)sourceID to:(NSCache *)cache directory:(NSString *)directoryPath
{
    if (image == nil || data == nil || sourceID == nil) {
        return;
    }
    
    NSString *keyForID = sourceID;
    [cache setObject:image forKey:keyForID];
    
    NSString *pathForID = [self pathForID:keyForID directory:directoryPath];
    [data writeToFile:pathForID atomically:YES];
}

- (void)storeTimelineImage:(UIImage *)image forUserID:(NSString *)userID
{
    if (nil == image || nil == userID) {
        return;
    }
    
    [self.timelineImageCache setObject:image forKey:userID];
}

- (void)storeUsersImage:(UIImage *)image forUserID:(NSString *)userID
{
    if (nil == image || nil == userID) {
        return;
    }
    
    [self.usersImageCache setObject:image forKey:userID];
}

- (void)storeCroppedMediaImage:(UIImage *)image forMediaID:(NSString *)mediaID
{
    if (!image || !mediaID || mediaID.length == 0) {
        return;
    }
    
    [self.croppedMediaImageCache setObject:image forKey:mediaID];
}

- (void)storeBannerImage:(UIImage *)image forUserID:(NSString *)userID
{
    if (!image || !userID || userID.length == 0) {
        return;
    }
    
    [self.bannerImageCache setObject:image forKey:userID];
}

#pragma mark -
#pragma mark cache downloadingURL
- (BOOL)isDownloadingImageWithUrlStr:(NSString *)urlStr
{
    BOOL isDownloading = NO;
    NSString *urlOfDownloading = [self.urlStringsForDownloadingImage objectForKey:urlStr];
    if (urlOfDownloading) {
        isDownloading = YES;
    } else {
        [self addUrlStrForDownloadingImage:urlStr];
    }
    
    return isDownloading;
}

- (void)addUrlStrForDownloadingImage:(NSString *)urlStr
{
    [self.urlStringsForDownloadingImage setObject:urlStr forKey:urlStr];
}

- (void)removeUrlStrForDownloadingImage:(NSString *)urlStr
{
    [self.urlStringsForDownloadingImage removeObjectForKey:urlStr];
}

#pragma mark -
#pragma mark crear Cache
- (void)clearMemoryCache
{
    [self.profileImageCache removeAllObjects];
    [self.mediaImageCache removeAllObjects];
    [self.croppedMediaImageCache removeAllObjects];
}

- (void)deleteAllCacheFiles
{
    [self clearMemoryCache];
    
    if ([self.fileManager fileExistsAtPath:self.cacheDirectory]) {
        if ([self.fileManager removeItemAtPath:self.cacheDirectory error:nil]) {
            [self createDirectories];
        }
    }
}

@end

//
//  MBImageCacher.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/09.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBImageCacher.h"
#import <CommonCrypto/CommonHMAC.h>

@interface MBImageCacher()

@property (nonatomic, readonly) NSFileManager *fileManager;
@property (nonatomic, readonly) NSString *cacheDirectory;
@property (nonatomic, readonly) NSString *profileImageDirectory;
@property (nonatomic, readonly) NSString *mediaImageDirectory;

@property (nonatomic, readonly) NSCache *profileImageCache;
@property (nonatomic, readonly) NSCache *mediaImageCache;

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
        self.profileImageCache.countLimit = 500;
        _mediaImageCache = [[NSCache alloc] init];
        self.mediaImageCache.countLimit = 100;
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
#pragma mark image
- (UIImage *)cachedProfileImageForUserID:(NSString *)userID
{
    return [self cachedProfileImageForUserID:userID defaultImage:nil];
}

- (UIImage *)cachedProfileImageForUserID:(NSString *)userID defaultImage:(UIImage *)defaultImage
{
    return [self cachedImageForID:userID defaultImage:defaultImage from:self.profileImageCache directory:self.profileImageDirectory];
}

- (UIImage *)cachedMediaImageForMediaID:(NSString *)mediaID
{
    return [self cachedImageForID:mediaID defaultImage:nil from:self.mediaImageCache directory:self.mediaImageDirectory];
}

- (UIImage *)cachedImageForID:(NSString *)sourceID defaultImage:(UIImage *)defaultImage from:(NSCache *)cache directory:(NSString *)directoryPath
{
    if (sourceID == nil) {
        return defaultImage;
    }
    
    NSString *keyForID = sourceID;
    UIImage *cachedImage = [cache objectForKey:keyForID];
    if (cachedImage) {
        return cachedImage;
    }
    
    NSString *pathForImage = [self pathForID:keyForID directory:directoryPath];
    cachedImage = [UIImage imageWithContentsOfFile:pathForImage];
    if (cachedImage) {
        return cachedImage;
    }
    
    return defaultImage;
}

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

#pragma mark -
#pragma mark crear Cache
- (void)crearMemoryCache
{
    [self.profileImageCache removeAllObjects];
    [self.mediaImageCache removeAllObjects];
}

- (void)deleteAllCacheFiles
{
    [self crearMemoryCache];
    
    if ([self.fileManager fileExistsAtPath:self.cacheDirectory]) {
        if ([self.fileManager removeItemAtPath:self.cacheDirectory error:nil]) {
            [self createDirectories];
        }
    }
}


@end

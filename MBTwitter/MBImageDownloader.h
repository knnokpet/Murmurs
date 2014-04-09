//
//  MBImageDownloader.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ImageDownloadCompletionHandler) (UIImage *image, NSData *imageData);
typedef void(^ImageDownloadFailedHandler) (NSURLResponse *response, NSError *error);

@interface MBImageDownloader : NSObject

+ (void)downloadImageWithURL:(NSString *)imageURL completionHandler:(ImageDownloadCompletionHandler)completionHandler failedHandler:(ImageDownloadFailedHandler)failedHandler;
- (void)downloadImageWithURL:(NSString *)imageURL completionHandler:(ImageDownloadCompletionHandler)completionHandler failedHandler:(ImageDownloadFailedHandler)failedHandler;

@end

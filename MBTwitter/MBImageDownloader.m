//
//  MBImageDownloader.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBImageDownloader.h"

@implementation MBImageDownloader

+ (void)downloadImageWithURL:(NSString *)imageURL completionHandler:(ImageDownloadCompletionHandler)completionHandler failedHandler:(ImageDownloadFailedHandler)failedHandler
{
    MBImageDownloader *downloader = [[MBImageDownloader alloc] init];
    [downloader downloadImageWithURL:imageURL completionHandler:completionHandler failedHandler:failedHandler];
}

+ (void)downloadOriginImageWithURL:(NSString *)imageURL completionHandler:(ImageDownloadCompletionHandler)completionHandler failedHandler:(ImageDownloadFailedHandler)failedHandler
{
    NSString *originURL = [imageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    MBImageDownloader *imageDownloader = [[MBImageDownloader alloc] init];
    [imageDownloader downloadImageWithURL:originURL completionHandler:completionHandler failedHandler:failedHandler];
}

+ (void)downloadBigImageWithURL:(NSString *)imageURL completionHandler:(ImageDownloadCompletionHandler)completionHandler failedHandler:(ImageDownloadFailedHandler)failedHandler
{
    NSString *originURL = [imageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
    MBImageDownloader *imageDownloader = [[MBImageDownloader alloc] init];
    [imageDownloader downloadImageWithURL:originURL completionHandler:completionHandler failedHandler:failedHandler];
}

- (void)downloadImageWithURL:(NSString *)imageURL completionHandler:(ImageDownloadCompletionHandler)completionHandler failedHandler:(ImageDownloadFailedHandler)failedHandler
{
    if (nil == imageURL || nil == completionHandler || nil == failedHandler) {
        return;
    }
    
    NSURL *requestURL = [NSURL URLWithString:imageURL];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *connectedData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:&response error:&error];
    if (!error) {
        UIImage *receivedImage = [[UIImage alloc] initWithData:connectedData];
        if (receivedImage) {

            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(receivedImage, connectedData);
            });
            
            
        } else {
            NSLog(@"not image");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
                failedHandler(response, error);
            });
            
        }
    } else {
        NSLog(@"occur error image");
        dispatch_async(dispatch_get_main_queue(), ^{
            failedHandler(response, error);
        });
        
    }
}

@end

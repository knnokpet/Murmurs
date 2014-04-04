//
//  MBUserManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBUserManager.h"

@implementation MBUserManager

+ (MBUserManager *)sharedInstance
{
    static MBUserManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MBUserManager alloc] initSharedInstance];
    });
    
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        ;
    }
    
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

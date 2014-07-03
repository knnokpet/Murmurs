//
//  MBTemporaryDirectMessage.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/18.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDirectMessage.h"

@interface MBTemporaryDirectMessage : MBDirectMessage

@property (nonatomic, readonly) MBUser *partner;
@property (nonatomic, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text partner:(MBUser *)partner;

@end

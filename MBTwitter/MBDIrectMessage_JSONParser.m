//
//  MBDIrectMessage_JSONParser.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/19.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDIrectMessage_JSONParser.h"
#import "MBDirectMessageManager.h"
#import "MBDirectMessage.h"

@implementation MBDIrectMessage_JSONParser

- (void)configure:(id)parsedObj
{
    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parsedDict = parsedObj;
        MBDirectMessage *message = [[MBDirectMessage alloc] initWithDictionary:parsedDict];
        [[MBDirectMessageManager sharedInstance] storeMessage:message];
        self.completion(@[message]);
    }
}

@end

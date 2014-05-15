//
//  MBAOuth_TwitterAPICenter.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBAOuth_TwitterAPICenter.h"
#import "MBAccountManager.h"
#import "MBAccount.h"
#import "OAMutableRequest.h"
#import "OAParameter.h"
#import "MBJSONParser.h"
#import "MBTweet_JSONParser.h"
#import "MBTweets_JSONParser.h"
#import "MBUser_JSONParser.h"
#import "MBUsers_JSONParser.h"
#import "MBLists_JSONParser.h"
#import "MBDirectMessages_JSONParser.h"
#import "MBGeocode_JSONPatser.h"
#import "MBHelp_JSONParser.h"

#import "OAAccessibility.h"
#import "MBTwitterConsumer.h"

@interface MBAOuth_TwitterAPICenter() <MBTwitterAPIHTTPConnecterDelegate>

@property (nonatomic, readonly) OAConsumer *consumer;
@property (nonatomic, readonly) OAToken *accessToken;
@end

@implementation MBAOuth_TwitterAPICenter

#pragma mark -
#pragma mark Initialize
- (id)init
{
    self = [super init];
    if (self) {
        _consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY secret:CONSUMER_SECRET];
        _accessToken = [[[MBAccountManager sharedInstance] currentAccount] accessToken];
        self.connections = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark -
#pragma mark APICenter Method : Connect

- (NSString *)sendRequestMethod:(NSString *)method resource:(NSString *)resource parameters:(NSDictionary *)parameters requestType:(MBRequestType)requestType responseType:(MBResponseType)responseType
{
    NSString *fullResource = [NSString stringWithFormat:@"%@://%@/%@/%@.%@", DEFAULT_CONNECTION_TYPE, DEFAULT_API_DOMAIN, DEFAULT_API_VERSION, resource, DEFAULT_API_EXTEND];
    NSURL *resourceURL = [NSURL URLWithString:fullResource];
    
    OAMutableRequest *request = [[OAMutableRequest alloc] initWithURL:resourceURL consumer:self.consumer token:_accessToken realm:nil signatureProvider:nil];
    if (!request) {
        return nil;
    }
    
    [request setHTTPMethod:method];
    
    if (nil != parameters) {
        if ([method isEqualToString:@"GET"]) {
            NSMutableArray *addingParameters = [NSMutableArray arrayWithArray:[request parameters]];
            [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                OAParameter *addingParam = [[OAParameter alloc] initWithName:(NSString *)key value:(NSString *)obj];
                [addingParameters addObject:addingParam];
            }];
            [request setParameters:addingParameters];
        } else { // POST
            [request setMultiPartPostParameters:parameters];
        }
    }
    
    [request prepareRequest];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (nil == data) {
                return ;
            }
            
            [self parseJSONData:data responseType:responseType];
        }];
        
    });
    
    return nil;
}
/*
- (void)failedConnecter:(MBTwitterAPIHTTPConnecter *)connecter error:(NSError *)error responseType:(MBResponseType)responseType
{
    
}

- (void)finishedConnecter:(MBTwitterAPIHTTPConnecter *)connecter data:(NSData *)data responseType:(MBResponseType)responseType
{
    if (NO == [self.connections objectForKey:[connecter identifier]] || nil == [self.connections objectForKey:[connecter identifier]]) {
        return;
    }
    
    [self parseJSONData:data responseType:responseType];
}*/

#pragma mark APICenter Methods : Parsed
- (void)parseJSONData:(NSData *)jsonData responseType:(MBResponseType)responseType
{
    MBJSONParser *jsonParser;
    
    switch (responseType) {
        case MBTwitterStatuseResponse: {
            jsonParser = [[MBTweet_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedTweets:)]) {
                        [_delegate twitterAPICenter:self parsedTweets:parsedObj];
                    }
                });
            }];
        }
            break;
            
        case MBTwitterStatusesResponse:{
            jsonParser = [[MBTweets_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedTweets:)]) {
                        [_delegate twitterAPICenter:self parsedTweets:parsedObj];
                    }
                });
            }];
        }
            break;
            
        case MBTwitterUserResponse: {
            jsonParser = [[MBUser_JSONParser alloc] initWithJSONData:jsonData completionHandler:^ (NSArray *parsedObj) {
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedUsers:)]) {
                    [_delegate twitterAPICenter:self parsedUsers:parsedObj];
                }
            }];
        }
            break;
        case MBTwitterUsersResponse: {
            jsonParser = [[MBUsers_JSONParser alloc] initWithJSONData:jsonData completionHandlerWithCursor:^ (NSArray *parsedObjects, NSNumber *next, NSNumber *previous) {
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedUsers:next:previous:)]) {
                    [_delegate twitterAPICenter:self parsedUsers:parsedObjects next:next previous:previous];
                }
            }];
        }
            break;
        case MBTwitterListsResponse: {
            jsonParser = [[MBLists_JSONParser alloc] initWithJSONData:jsonData completionHandler:^ (NSArray *parsedObj) {
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedLists:)]) {
                    [_delegate twitterAPICenter:self parsedLists:parsedObj];
                }
            }];
        }
            break;
        case MBTwitterDirectMessagesResponse: {
            jsonParser = [[MBDirectMessages_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedDirectMessages:)]) {
                        [_delegate twitterAPICenter:self parsedDirectMessages:parsedObj];
                    }
                });
            }];
        }
            break;
        case MBTwitterDirectMessageResponse: {
            jsonParser = [[MBDirectMessages_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedDirectMessages:)]) {
                        [_delegate twitterAPICenter:self parsedDirectMessages:parsedObj];
                    }
                });
            }];
        }
            break;
        case MBTwitterGeocodeResponse: {
            jsonParser = [[MBGeocode_JSONPatser alloc] initWithJSONData:jsonData completionHandler:^ (NSArray *parsedObj) {
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedPlaces:)]) {
                    [_delegate twitterAPICenter:self parsedPlaces:parsedObj];
                }
            }];
        }
            break;
            
        case MBTwitterHelpResponse:
        {
            jsonParser = [[MBHelp_JSONParser alloc] initWithJSONData:jsonData completionHandler:nil];
        }
            break;
            
        default:
            break;
    }
    
    [jsonParser startParsing];
}

@end

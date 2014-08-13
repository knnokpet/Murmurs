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
#import "MBSearchedTweets_JSONParser.h"
#import "MBUser_JSONParser.h"
#import "MBUsers_JSONParser.h"
#import "MBUsersLookUp_JSONParser.h"
#import "MBUserIDs_JSONParser.h"
#import "MBRelationships_JSONParser.h"
#import "MBList_JSONParser.h"
#import "MBLists_JSONParser.h"
#import "MBDirectMessages_JSONParser.h"
#import "MBDIrectMessage_JSONParser.h"
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
    
    id __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                NSLog(@"code %d error = %@", error.code, error.localizedDescription);
            }
            if (nil == data) {
                return ;
            }
            
            
            [weakSelf parseJSONData:data responseType:responseType requestType:requestType];
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
- (void)parseJSONData:(NSData *)jsonData responseType:(MBResponseType)responseType requestType:(MBRequestType)requestType
{
    MBJSONParser *jsonParser;
    id __weak weakSelf = self;
    if (responseType == MBTwitterStatuseResponse) {
        jsonParser = [[MBTweet_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:requestType:parsedTweets:)]) {
                    [_delegate twitterAPICenter:weakSelf requestType:(MBRequestType)requestType parsedTweets:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterStatusesResponse) {
        jsonParser = [[MBTweets_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:requestType:parsedTweets:)]) {
                    [_delegate twitterAPICenter:weakSelf requestType:(MBRequestType)requestType parsedTweets:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterSearchedStatusesResponse) {
        jsonParser = [[MBSearchedTweets_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:requestType:parsedTweets:)]) {
                    [_delegate twitterAPICenter:weakSelf requestType:(MBRequestType)requestType parsedTweets:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterUserResponse) {
        jsonParser = [[MBUser_JSONParser alloc] initWithJSONData:jsonData completionHandler:^ (NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:requestType:parsedUsers:)]) {
                    [_delegate twitterAPICenter:weakSelf requestType:requestType parsedUsers:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterUsersResponse) {
        jsonParser = [[MBUsers_JSONParser alloc] initWithJSONData:jsonData completionHandlerWithCursor:^ (NSArray *parsedObjects, NSNumber *next, NSNumber *previous) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedUsers:next:previous:)]) {
                    [_delegate twitterAPICenter:weakSelf parsedUsers:parsedObjects next:next previous:previous];
                }
            });
        }];
        
    } else if (responseType == MBTwitterUsersLookUpResponse) {
        jsonParser = [[MBUsersLookUp_JSONParser alloc] initWithJSONData:jsonData completionHandler:^ (NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:requestType:parsedUsers:)]) {
                    [_delegate twitterAPICenter:weakSelf requestType:requestType parsedUsers:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterUserIDsResponse) {
        jsonParser = [[MBUserIDs_JSONParser alloc] initWithJSONData:jsonData completionHandlerWithCursor:^(NSArray *parsedObjects, NSNumber *next, NSNumber *previous) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedUserIDs:next:previous:)]) {
                    [_delegate twitterAPICenter:weakSelf parsedUserIDs:parsedObjects next:next previous:previous];
                }
            });
        }];
        
    } else if (responseType == MBTwitterUserRelationshipsResponse) {
        jsonParser = [[MBRelationships_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObjects) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:relationships:)]) {
                    [_delegate twitterAPICenter:weakSelf relationships:parsedObjects];
                }
            });
        }];
        
    } else if (responseType == MBTwitterListResponse) {
        jsonParser = [[MBList_JSONParser alloc] initWithJSONData:jsonData completionHandler:^ (NSArray *parsedObj){
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedLists:)]) {
                    [_delegate twitterAPICenter:weakSelf parsedLists:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterListsResponse) {
        jsonParser = [[MBLists_JSONParser alloc] initWithJSONData:jsonData completionHandlerWithCursor:^ (NSArray *parsedObjects, NSNumber *next, NSNumber *previous) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedLists:next:previous:)]) {
                    [_delegate twitterAPICenter:weakSelf parsedLists:parsedObjects next:next previous:previous];
                }
            });
        }];
        
    } else if (responseType == MBTwitterDirectMessagesResponse) {
        jsonParser = [[MBDirectMessages_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedDirectMessages:)]) {
                    [_delegate twitterAPICenter:weakSelf parsedDirectMessages:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterDirectMessageResponse) {
        jsonParser = [[MBDIrectMessage_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedDirectMessages:)]) {
                    [_delegate twitterAPICenter:weakSelf parsedDirectMessages:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterGeocodeResponse) {
        jsonParser = [[MBGeocode_JSONPatser alloc] initWithJSONData:jsonData completionHandler:^ (NSArray *parsedObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:parsedPlaces:)]) {
                    [_delegate twitterAPICenter:weakSelf parsedPlaces:parsedObj];
                }
            });
        }];
        
    } else if (responseType == MBTwitterHelpResponse) {
        jsonParser = [[MBHelp_JSONParser alloc] initWithJSONData:jsonData completionHandler:^(NSArray *parsedObj) {
            
            NSNumber *medias = [parsedObj firstObject];
            NSNumber *shortURLLength = [parsedObj objectAtIndex:1];
            NSNumber *photoLimit = [parsedObj lastObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(twitterAPICenter:maxMedias:photoSizeLimit:shortURLLength:)]) {
                    [_delegate twitterAPICenter:weakSelf maxMedias:medias photoSizeLimit:photoLimit shortURLLength:shortURLLength];
                }
            });
        }];
        
    }
    
    [jsonParser setErrorCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(twitterAPICenter:error:)]) {
                [_delegate twitterAPICenter:weakSelf error:error];
            }
        });
    }];
    
    [jsonParser startParsing];
}

@end

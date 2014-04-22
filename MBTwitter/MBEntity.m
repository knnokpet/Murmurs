//
//  MBEntity.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/31.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBEntity.h"
#import "MBHashTagLink.h"
#import "MBMediaLink.h"
#import "MBURLLink.h"
#import "MBMentionUserLink.h"

#define ENTITY_KEY_HASHTAG @"hashtags"
#define ENTITY_KEY_MEDIA @"media"
#define ENTITY_KEY_URLS @"urls"
#define ENTITY_KEY_USER_MENTHIONS @"user_mentions"

@implementation MBEntity
- (id)initWithDictionary:(NSDictionary *)entity
{
    self = [super init];
    if (self) {
        [self initializeWithDictionary:entity];
    }
    
    return self;
}

- (void)initializeWithDictionary:(NSDictionary *)entity
{
    
    NSArray *parsedHashTags = [entity arrayForKey:ENTITY_KEY_HASHTAG];
    NSArray *parsedMedia = [entity arrayForKey:ENTITY_KEY_MEDIA];
    NSArray *parsedURLs = [entity arrayForKey:ENTITY_KEY_URLS];
    NSArray *parsedMentions = [entity arrayForKey:ENTITY_KEY_USER_MENTHIONS];
    
    [self configureEntityFromParsedArray:parsedHashTags forKey:ENTITY_KEY_HASHTAG];
    [self configureEntityFromParsedArray:parsedMedia forKey:ENTITY_KEY_MEDIA];
    [self configureEntityFromParsedArray:parsedURLs forKey:ENTITY_KEY_MEDIA];
    [self configureEntityFromParsedArray:parsedMentions forKey:ENTITY_KEY_USER_MENTHIONS];
    
}

- (void)configureEntityFromParsedArray:(NSArray *)fromArray forKey:(NSString *)key
{
    if (nil == fromArray) {
        return;
    }
    
    NSInteger containsCount = [fromArray count];
    NSMutableArray *entities = [NSMutableArray arrayWithCapacity:containsCount];
    
    for (NSDictionary *entity in fromArray) {
        MBLink *linkObj;
        if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_HASHTAG]) {
            linkObj = [[MBHashTagLink alloc] initWithDictionary:entity];
        } else if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_MEDIA]) {
            linkObj = [[MBMediaLink alloc] initWithDictionary:entity];
        } else if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_URLS]) {
            linkObj = [[MBURLLink alloc] initWithDictionary:entity];
        } else if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_USER_MENTHIONS]) {
            linkObj = [[MBMentionUserLink alloc] initWithDictionary:entity];
        }
        
        [entities addObject:linkObj];
    }
    
    if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_HASHTAG]) {
        _hashtags = entities;
    } else if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_MEDIA]) {
        _media = entities;
    } else if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_URLS]) {
        _urls = entities;
    } else if (NSOrderedSame == [key isEqualToString:ENTITY_KEY_USER_MENTHIONS]) {
        _userMentions = entities;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _hashtags = [aDecoder decodeObjectForKey:ENTITY_KEY_HASHTAG];
        _media = [aDecoder decodeObjectForKey:ENTITY_KEY_MEDIA];
        _urls = [aDecoder decodeObjectForKey:ENTITY_KEY_URLS];
        _userMentions = [aDecoder decodeObjectForKey:ENTITY_KEY_USER_MENTHIONS];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_hashtags forKey:ENTITY_KEY_HASHTAG];
    [aCoder encodeObject:_media forKey:ENTITY_KEY_MEDIA];
    [aCoder encodeObject:_urls forKey:ENTITY_KEY_URLS];
    [aCoder encodeObject:_userMentions forKey:ENTITY_KEY_USER_MENTHIONS];
}

@end

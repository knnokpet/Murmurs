//
//  MBTimeLineManager.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/26.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimeLineManager.h"
#import "MBTweetManager.h"
#import "MBTweet.h"
#import "MBGapedTweet.h"

#define UPDATE_KEY @"update"
#define REMOVE_KEY @"remove"

@interface MBTimeLineManager()
@property (nonatomic, readonly) NSMutableArray *sourceTweets;

@end

@implementation MBTimeLineManager
#pragma mark -
#pragma mark Inisialize
- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    _sourceTweets = [NSMutableArray array];
    _gaps = [NSMutableArray array];
}

#pragma mark -
#pragma mark Setter & Getter
- (NSArray *)tweets
{
    NSMutableArray *tweets = self.sourceTweets.mutableCopy;
    for (MBGapedTweet *gap in self.gaps) {
        NSInteger index = gap.index;
        [tweets insertObject:gap atIndex:index];
        NSLog(@"add gap");
    }
    
    return tweets;
}


#pragma mark -

- (NSDictionary *)addTweets:(NSArray *)tweets
{
    if (0 == [tweets count]) {
        return nil;
    }
    
    NSMutableDictionary *updates = [NSMutableDictionary dictionary];
    
    NSInteger gapsCount = [self.gaps count];
    if (0 < gapsCount) {
        for (NSInteger index = 0; index < gapsCount; index ++) {
            BOOL isBeingAmong = [self isBeingAmong:tweets gap:self.gaps[index]];
            if (YES == isBeingAmong) {
                MBGapedTweet *gapedTweet = self.gaps[index];
                MBTweet *lastAddingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];
                MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.sourceTweets[gapedTweet.index]];
                
                
                NSComparisonResult result = [self compareTweet:firstExistingTweet with:lastAddingTweet];
                switch (result) {
                    case NSOrderedAscending: {
                        
                        NSInteger addingIndex = [tweets count];
                        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(gapedTweet.index, addingIndex)];
                        [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
                        [updates setObject:indexSet forKey:UPDATE_KEY];

                        // 足された分、残りの Gap.index をずらす
                        for (NSInteger i = index ; i < gapsCount; i ++) {
                            MBGapedTweet *gap = self.gaps[i];
                            gap.index = gap.index + addingIndex;
                        }
                        
                    }break;
                        
                    case NSOrderedSame: {
                        // 差分チェック用のオブジェクトが被るので追加データから削除
                        NSMutableArray *addingTweets = tweets.mutableCopy;
                        [addingTweets removeLastObject];
                        
                        NSInteger addingIndex = [addingTweets count];
                        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(gapedTweet.index, addingIndex)];
                        [self.sourceTweets insertObjects:addingTweets atIndexes:indexSet];
                        [updates setObject:indexSet forKey:UPDATE_KEY];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[indexSet lastIndex] + 1 inSection:0];
                        [updates setObject:indexPath forKey:REMOVE_KEY];
                        
                        // 足された分、残りの Gap.index をずらす
                        for (NSInteger i = index + 1; i < gapsCount; i ++) {
                            MBGapedTweet *gapedTweet = self.gaps[i];
                            gapedTweet.index = gapedTweet.index + addingIndex;
                        }
                        [self.gaps removeObjectAtIndex:index];
                        
                    }break;
                        
                    case NSOrderedDescending: {
                        NSLog(@"きてはならない");
                        return nil;
                    }break;
                        
                    default:
                        break;
                }
                
            } else { // NO == isBeingAmong
                
                MBTweet *lastAddingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];
                MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets firstObject]];
                
                NSComparisonResult result = [self compareTweet:firstExistingTweet with:lastAddingTweet];
                switch (result) {
                    case NSOrderedAscending: {
                        NSInteger addingTweetsIndex = [tweets count];
                        MBGapedTweet *gapedTweets = [[MBGapedTweet alloc] initWithIndex:addingTweetsIndex];
                        [self.gaps addObject:gapedTweets];
                        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
                        [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
                        [indexSet addIndex:addingTweetsIndex + 1];
                        [updates setObject:indexSet forKey:UPDATE_KEY];
                        
                        // 足された分、残りの Gap.index をずらす
                        for (MBGapedTweet *gap in self.gaps) {
                            gap.index = gap.index + addingTweetsIndex + 1;
                        }
                        
                    }break;
                    case NSOrderedSame: {
                        // 差分チェック用のオブジェクトが被るので追加データから削除
                        NSMutableArray *addingTweets = tweets.mutableCopy;
                        [addingTweets removeLastObject];
                        NSInteger addingTweetsIndex = [addingTweets count];
                        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
                        [self.sourceTweets insertObjects:addingTweets atIndexes:indexSet];
                        [updates setObject:indexSet forKey:UPDATE_KEY];
                        
                        // 足された分、残りの Gap.index をずらす
                        for (MBGapedTweet *gap in self.gaps) {
                            gap.index = gap.index + addingTweetsIndex;
                        }
                        
                    }break;
                    case NSOrderedDescending: {
                        [self.sourceTweets addObjectsFromArray:tweets];
                        NSInteger addingIndex = [tweets count];
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingIndex)];
                        [updates setObject:indexSet forKey:UPDATE_KEY];
                    }break;
                        
                    default:
                        break;
                }
                
                return updates;
            }
        }

        return updates;
    } else {
        MBTweet *lastAddingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];
        MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets firstObject]];
        
        NSComparisonResult result = [self compareTweet:firstExistingTweet with:lastAddingTweet];
        switch (result) {
            case NSOrderedAscending: {
                NSInteger addingTweetsIndex = [tweets count];
                MBGapedTweet *gapedTweets = [[MBGapedTweet alloc] initWithIndex:addingTweetsIndex];
                [self.gaps addObject:gapedTweets];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
                [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
                [indexSet addIndex:addingTweetsIndex + 1];
                [updates setObject:indexSet forKey:UPDATE_KEY];
                
            }break;
            case NSOrderedSame: {
                // 差分チェック用のオブジェクトが被るので追加データから削除
                NSMutableArray *addingTweets = tweets.mutableCopy;
                [addingTweets removeLastObject];
                NSInteger addingTweetsIndex = [addingTweets count];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
                [self.sourceTweets insertObjects:addingTweets atIndexes:indexSet];
                [updates setObject:indexSet forKey:UPDATE_KEY];
                
            }break;
            case NSOrderedDescending: {
                [self.sourceTweets addObjectsFromArray:tweets];
                NSInteger addingIndex = [tweets count];
                NSLog(@"addingindex = %d", addingIndex);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingIndex)];
                [updates setObject:indexSet forKey:UPDATE_KEY];
            }break;
                
            default:
                break;
        }

        return updates;
    }
}

- (NSComparisonResult)compareTweet:(MBTweet *)aTweet with:(MBTweet *)bTweet
{
    if (nil == aTweet || nil == bTweet ) {
        return NSOrderedDescending;
    }
    
    NSComparisonResult result = [aTweet.tweetID compare:bTweet.tweetID];
    return result;
}

- (BOOL)isBeingAmong:(NSArray *)tweets gap:(MBGapedTweet *)gap
{
    // minus for since
    NSMutableArray *addingTweets = tweets.mutableCopy;
    [addingTweets removeLastObject];
    
    NSInteger abobeIndex = gap.index - 1;
    NSInteger belowIndex = gap.index + 1;
    MBTweet *existAbobe = [[MBTweetManager sharedInstance] storedTweetForKey:self.sourceTweets[abobeIndex]];
    MBTweet *existBelow = [[MBTweetManager sharedInstance] storedTweetForKey:self.sourceTweets[belowIndex]];
    MBTweet *addingAbobe = [[MBTweetManager sharedInstance] storedTweetForKey:[addingTweets firstObject]];
    MBTweet *addingBelow = [[MBTweetManager sharedInstance] storedTweetForKey:[addingTweets lastObject]];
    
    NSComparisonResult abobeResult = [self compareTweet:existAbobe with:addingAbobe];
    NSComparisonResult belowResult = [self compareTweet:existBelow with:addingBelow];
    NSLog(@"result = %d, result = %d", abobeResult, belowResult);
    if (NSOrderedDescending == abobeResult && NSOrderedAscending == belowResult) {
        return YES;
    }
    
    return NO;
}

@end

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
//#define REMOVE_KEY @"remove"
#define GAPS_KEY @"gaps"
#define ADDING_GAP_KEY @"addingGap"
#define ADDING_DATA_KEY @"addingData"

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
    NSMutableArray *tweets = [NSMutableArray arrayWithArray:self.sourceTweets];
    for (MBGapedTweet *gap in self.gaps) {
        NSInteger index = gap.index;
        [tweets insertObject:gap atIndex:index];
    }
    
    return tweets;
}


#pragma mark -

- (NSDictionary *)addTweets:(NSArray *)tweets
{
    if (tweets.count <= 1) {
        /* sinceTweet がそのまま１つだけ帰ってきた場合、tableView の更新は行わないため */
        return nil;
    }
    
    NSMutableDictionary *updates = [NSMutableDictionary dictionary];
    [updates setObject:tweets forKey:ADDING_DATA_KEY];
    
    NSInteger gapsCount = [self.gaps count];
    if (0 < gapsCount) {
        
        for (NSInteger index = 0; index < gapsCount; index ++) {
            BOOL isAddingGaps = [self isAddingGaps:tweets gap:self.gaps[index]];
            if (YES == isAddingGaps) {
                MBGapedTweet *gapedTweet = self.gaps[index];
                MBTweet *lastAddingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];
                MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:self.sourceTweets[gapedTweet.index]];
                
                
                NSComparisonResult result = [self compareTweet:firstExistingTweet with:lastAddingTweet];
                if (result == NSOrderedAscending) {
                    NSInteger addingIndex = [tweets count];
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(gapedTweet.index, addingIndex)];
                    [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
                    
                    
                    // 足された分、残りの Gap.index をずらす
                    for (NSInteger i = index ; i < gapsCount; i ++) {
                        MBGapedTweet *gap = self.gaps[i];
                        gap.index = gap.index + addingIndex;
                    }
                    [updates setObject:[NSNumber numberWithBool:YES] forKey:UPDATE_KEY];
                    [updates setObject:[NSNumber numberWithBool:YES] forKey:GAPS_KEY];
                    
                } else if (result == NSOrderedSame) {
                    // 差分チェック用のオブジェクトが被るので追加データから削除
                    NSMutableArray *addingTweets = tweets.mutableCopy;
                    [addingTweets removeLastObject];
                    [updates setObject:addingTweets forKey:ADDING_DATA_KEY];
                    
                    NSInteger addingIndex = [addingTweets count];
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(gapedTweet.index, addingIndex)];
                    [self.sourceTweets insertObjects:addingTweets atIndexes:indexSet];
                    [updates setObject:indexSet forKey:UPDATE_KEY];
                    
                    // 足された分、残りの Gap.index をずらす
                    for (NSInteger i = index + 1; i < gapsCount; i ++) {
                        MBGapedTweet *gapedTweet = self.gaps[i];
                        gapedTweet.index = gapedTweet.index + addingIndex;
                    }
                    [self.gaps removeObjectAtIndex:index];
                    
                    [updates setObject:[NSNumber numberWithBool:NO] forKey:UPDATE_KEY];
                    [updates setObject:[NSNumber numberWithBool:NO] forKey:GAPS_KEY];
                    
                } else if (result == NSOrderedDescending) {
                    NSLog(@"きてはならない");
                }
                [updates setObject:[NSNumber numberWithBool:YES] forKey:ADDING_GAP_KEY];
                
            } else {
                
                MBTweet *lastAddingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];
                MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets firstObject]];
                
                NSComparisonResult result = [self compareTweet:firstExistingTweet with:lastAddingTweet];
                if (result == NSOrderedAscending) {
                    NSInteger addingTweetsIndex = [tweets count];
                    MBGapedTweet *gapedTweets = [[MBGapedTweet alloc] initWithIndex:addingTweetsIndex];
                    [self.gaps addObject:gapedTweets];
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
                    [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
                    [indexSet addIndex:addingTweetsIndex + 1];
                    
                    
                    // 足された分、残りの Gap.index をずらす
                    for (MBGapedTweet *gap in self.gaps) {
                        gap.index = gap.index + addingTweetsIndex + 1;
                    }
                    
                    [updates setObject:[NSNumber numberWithBool:YES] forKey:UPDATE_KEY];
                    [updates setObject:[NSNumber numberWithBool:YES] forKey:GAPS_KEY];
                    
                } else if (result == NSOrderedSame) {
                    // 差分チェック用のオブジェクトが被るので追加データから削除
                    NSMutableArray *addingTweets = tweets.mutableCopy;
                    [addingTweets removeLastObject];
                    [updates setObject:addingTweets forKey:ADDING_DATA_KEY];
                    
                    NSInteger addingTweetsIndex = [addingTweets count];
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
                    [self.sourceTweets insertObjects:addingTweets atIndexes:indexSet];
                    
                    
                    // 足された分、残りの Gap.index をずらす
                    for (MBGapedTweet *gap in self.gaps) {
                        gap.index = gap.index + addingTweetsIndex;
                    }
                    
                    [updates setObject:[NSNumber numberWithBool:YES] forKey:UPDATE_KEY];
                    [updates setObject:[NSNumber numberWithBool:NO] forKey:GAPS_KEY];
                    
                } else if (result == NSOrderedDescending) {
                    [self.sourceTweets addObjectsFromArray:tweets];
                    
                    [updates setObject:[NSNumber numberWithBool:NO] forKey:UPDATE_KEY];
                    
                }
            }
        }
        return updates;
        
    } else {
        MBTweet *lastAddingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];
        MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets firstObject]];
        
        NSComparisonResult result = [self compareTweet:firstExistingTweet with:lastAddingTweet];
        if (result == NSOrderedAscending) {
            NSInteger addingTweetsIndex = [tweets count];
            MBGapedTweet *gapedTweets = [[MBGapedTweet alloc] initWithIndex:addingTweetsIndex];
            [self.gaps addObject:gapedTweets];
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
            [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
            [indexSet addIndex:addingTweetsIndex + 1];
            
            [updates setObject:[NSNumber numberWithBool:YES] forKey:UPDATE_KEY];
            [updates setObject:[NSNumber numberWithBool:YES] forKey:GAPS_KEY];
            
        } else if (result == NSOrderedSame) {
            // 差分チェック用のオブジェクトが被るので追加データから削除
            NSMutableArray *addingTweets = tweets.mutableCopy;
            [addingTweets removeLastObject];
            [updates setObject:addingTweets forKey:ADDING_DATA_KEY];
            
            NSInteger addingTweetsIndex = [addingTweets count];
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
            [self.sourceTweets insertObjects:addingTweets atIndexes:indexSet];
            
            [updates setObject:[NSNumber numberWithBool:YES] forKey:UPDATE_KEY];
            [updates setObject:[NSNumber numberWithBool:NO] forKey:GAPS_KEY];
            
        } else if (result == NSOrderedDescending) {
            [self.sourceTweets addObjectsFromArray:tweets];
            
            [updates setObject:[NSNumber numberWithBool:NO] forKey:UPDATE_KEY];
            
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

- (BOOL)isAddingGaps:(NSArray *)tweets gap:(MBGapedTweet *)gap
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
    if (NSOrderedDescending == abobeResult && NSOrderedAscending == belowResult) {
        return YES;
    }
    
    return NO;
}

- (void)removeTweetAtIndex:(NSUInteger)index
{
    
    NSInteger countOfEarlyGaps = 0;
    for (MBGapedTweet *gap in self.gaps) {
        if (gap.index == index) { /* ありえない */
            return;
        }
        if (gap.index > index) {
            break;
        }
        
        countOfEarlyGaps ++;
    }
    NSUInteger removeIndex = index - countOfEarlyGaps;
    [self.sourceTweets removeObjectAtIndex:removeIndex];
    
}

@end

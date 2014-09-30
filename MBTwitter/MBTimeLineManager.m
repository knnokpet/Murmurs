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
    _saveIndex = 0;
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
    
    NSMutableDictionary *updates = [NSMutableDictionary dictionary];
    [updates setObject:tweets forKey:ADDING_DATA_KEY];
    
    NSInteger gapsCount = [self.gaps count];
    
    if (0 < gapsCount) {
        
        NSInteger indexOfGap = 0;
        BOOL isAddingGaps = NO;
        for (MBGapedTweet *gapedTweet in self.gaps) {
            isAddingGaps = [self isAddingGaps:tweets gap:gapedTweet indexOfGap:indexOfGap];
            if (isAddingGaps) {
                break;
            }
            indexOfGap++;
        }
        
        if (YES == isAddingGaps) {
            MBGapedTweet *gapedTweet = self.gaps[indexOfGap];
            NSInteger minusGapsIndex = gapedTweet.index - indexOfGap;
            MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:_sourceTweets[minusGapsIndex]];
            MBTweet *lastExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets lastObject]];
            
            NSComparisonResult result = [self comparisonResultWithTweets:tweets existingFirst:firstExistingTweet existingLast:lastExistingTweet];
            if (result == NSOrderedAscending) {
                NSInteger addingIndex = [tweets count];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(minusGapsIndex, addingIndex)];
                [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
                
                
                // 足された分、残りの Gap.index をずらす
                NSInteger indexOfAddingGap = 0;
                for (MBGapedTweet *gapedTweet in self.gaps) {
                    if (indexOfAddingGap >= indexOfGap) {
                        gapedTweet.index = gapedTweet.index + addingIndex;
                    }
                    indexOfAddingGap ++;
                }
                
                [updates setObject:[NSNumber numberWithBool:YES] forKey:UPDATE_KEY];
                [updates setObject:[NSNumber numberWithBool:YES] forKey:GAPS_KEY];
                
            } else if (result == NSOrderedSame) {
                // 差分チェック用のオブジェクトが被るので追加データから削除
                NSMutableArray *addingTweets = tweets.mutableCopy;
                [addingTweets removeLastObject];
                [updates setObject:addingTweets forKey:ADDING_DATA_KEY];
                
                NSInteger addingIndex = [addingTweets count];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(minusGapsIndex, addingIndex)];
                [self.sourceTweets insertObjects:addingTweets atIndexes:indexSet];
                
                
                // 足された分、残りの Gap.index をずらす
                NSInteger indexOfAddingGap = 0;
                for (MBGapedTweet *gapedTweet in self.gaps) {
                    if (indexOfAddingGap > indexOfGap) {
                        gapedTweet.index = gapedTweet.index + addingIndex;
                    }
                    indexOfAddingGap ++;
                }
                [self.gaps removeObjectAtIndex:indexOfGap];
                
                [updates setObject:[NSNumber numberWithBool:NO] forKey:UPDATE_KEY];
                [updates setObject:[NSNumber numberWithBool:NO] forKey:GAPS_KEY];
                
            } else if (result == NSOrderedDescending) {
                NSLog(@"きてはならない");
            }
            [updates setObject:[NSNumber numberWithBool:YES] forKey:ADDING_GAP_KEY];
            
        } else { // Top or Bottom への追加。
            
            MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets firstObject]];
            MBTweet *lastExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets lastObject]];
            
            NSComparisonResult result = [self comparisonResultWithTweets:tweets existingFirst:firstExistingTweet existingLast:lastExistingTweet];
            if (result == NSOrderedAscending) {
                NSInteger addingTweetsIndex = [tweets count];
                
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
                [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
                
                
                // 足された分、残りの Gap.index をずらす
                for (MBGapedTweet *gap in self.gaps) {
                    gap.index = gap.index + addingTweetsIndex + 1;
                }
                MBGapedTweet *gapedTweet = [[MBGapedTweet alloc] initWithIndex:addingTweetsIndex];
                [self addGapedTweet:gapedTweet];
                
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
                MBTweet *lastExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[self.sourceTweets lastObject]];
                [self.sourceTweets addObjectsFromArray:[self removeSavedDuplicatingTweets:tweets lastExistingTweet:lastExistingTweet]];
                
                [updates setObject:[NSNumber numberWithBool:NO] forKey:UPDATE_KEY];
                
            }
        }

        return updates;
        
    } else {
        MBTweet *firstExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets firstObject]];
        MBTweet *lastExistingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[_sourceTweets lastObject]];
        
        NSComparisonResult result = [self comparisonResultWithTweets:tweets existingFirst:firstExistingTweet existingLast:lastExistingTweet];
        
        if (result == NSOrderedAscending) {
            NSInteger addingTweetsIndex = [tweets count];
            MBGapedTweet *gapedTweet = [[MBGapedTweet alloc] initWithIndex:addingTweetsIndex];
            [self addGapedTweet:gapedTweet];
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addingTweetsIndex)];
            [self.sourceTweets insertObjects:tweets atIndexes:indexSet];
            
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

- (NSComparisonResult)comparisonResultWithTweets:(NSArray *)tweets existingFirst:(MBTweet *)firstTweet existingLast:(MBTweet *)lastTweet
{
    MBTweet *addingFirst = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets firstObject]];
    MBTweet *addingLast = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];
    NSComparisonResult result = NSOrderedDescending;
    
    if (!firstTweet || !lastTweet || !addingFirst || !addingLast) {
        return result;
    }
    
    // check backTimeline
    if (([lastTweet.tweetID compare:addingFirst.tweetID] == NSOrderedDescending) && ([lastTweet.tweetID compare:addingLast.tweetID] == NSOrderedDescending)) {
        return result;
    }
    
    // 上に足されるかギャップを埋めるか。
    result = NSOrderedAscending;
    if ([firstTweet.tweetID compare:addingLast.tweetID] == NSOrderedSame) {
        result = NSOrderedSame;
        return result;
    }
    
    if ([firstTweet.tweetID compare:addingFirst.tweetID] == NSOrderedAscending || [firstTweet.tweetID compare:addingLast.tweetID] == NSOrderedAscending) {
    }
    
    return result;
}

- (NSComparisonResult)compareTweet:(MBTweet *)receivedTweet with:(MBTweet *)givenTweet
{
    if (nil == receivedTweet || nil ==givenTweet ) {
        return NSOrderedDescending;
    }
    
    return [receivedTweet.tweetID compare:givenTweet.tweetID];
}

- (BOOL)isAddingGaps:(NSArray *)tweets gap:(MBGapedTweet *)gap indexOfGap:(NSInteger)indexOfGap
{
    NSInteger indexMinusGaps = gap.index - indexOfGap; /* gap.index はギャップも含んだ値なので。 */
    NSInteger abobeIndex = indexMinusGaps - 1;
    NSInteger belowIndex = indexMinusGaps + 1;// gap が超えたらたらバグるね。
    MBTweet *existAbobe = [[MBTweetManager sharedInstance] storedTweetForKey:self.sourceTweets[abobeIndex]];
    MBTweet *existBelow = [[MBTweetManager sharedInstance] storedTweetForKey:self.sourceTweets[belowIndex]];
    MBTweet *addingAbobe = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets firstObject]];
    MBTweet *addingBelow = [[MBTweetManager sharedInstance] storedTweetForKey:[tweets lastObject]];

    NSComparisonResult abobeResult = [self compareTweet:existAbobe with:addingAbobe];
    NSComparisonResult belowResult = [self compareTweet:existBelow with:addingBelow];
    if (abobeResult == NSOrderedDescending && belowResult == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

- (NSArray *)removeSavedDuplicatingTweets:(NSArray *)sourceTweets lastExistingTweet:(MBTweet *)existTweet
{
    MBTweet *firstAddingTweet = [[MBTweetManager sharedInstance] storedTweetForKey:[sourceTweets firstObject]];
    if (!existTweet || firstAddingTweet) {
        return sourceTweets;
    }
    
    if (firstAddingTweet.tweetID < existTweet.tweetID) {
        return sourceTweets;
    }
    
    if ([existTweet.tweetID compare:firstAddingTweet.tweetID] == NSOrderedDescending) {
        return sourceTweets;
    }
    
    NSInteger index = 0;
    for (NSString *key in sourceTweets) {
        MBTweet *tweet = [[MBTweetManager sharedInstance] storedTweetForKey:key];
        if (tweet.tweetID < existTweet.tweetID) {
            break;
        }
        index++;
    }
    
    NSMutableArray *removedTweets = sourceTweets.mutableCopy;
    [removedTweets removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    return removedTweets;
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
        } else {
            gap.index = gap.index - 1;
        }
        
        countOfEarlyGaps ++;
    }
    NSUInteger removeIndex = index - countOfEarlyGaps;
    [self.sourceTweets removeObjectAtIndex:removeIndex];
    
}

- (void)addGapedTweet:(MBGapedTweet *)addedTweet
{
    [self.gaps addObject:addedTweet];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [self.gaps sortUsingDescriptors:@[descriptor]];
    /*
    NSInteger index = 0;
    for (MBGapedTweet *gaped in self.gaps) {
        if (addedTweet.index > gaped.index) {
            break;
        }
        index++;
    }
    
    [self.gaps insertObject:addedTweet atIndex:index];*/
}

- (void)addSaveIndex
{
    _saveIndex++;
}

- (void)stopLoadingSavedTweets
{
    _saveIndex = -1;
}

@end

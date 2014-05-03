//
//  MBTweetTextComposer.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/23.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTweetTextComposer.h"
#import <CoreText/CoreText.h>
#import "MBTwitterAccessibility.h"

@implementation MBTweetTextComposer

+ (NSAttributedString *)attributedStringForTweet:(MBTweet *)tweet
{
    if (nil == tweet) {
        return [[NSAttributedString alloc] init];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    
    UIColor *defaultTextColor = [UIColor blackColor];
    UIColor *linkTextColor = [UIColor blueColor];
    
    NSString *tweetText = tweet.tweetText;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tweetText attributes:@{(id)kCTForegroundColorAttributeName: (id)defaultTextColor, (id)kCTFontAttributeName: (__bridge id)fontRef}];
    CFRelease(fontRef);
    
    
    MBEntity *entity = tweet.entity;
    
    // hashtag
    NSArray *hashtags = entity.hashtags;
    for (MBHashTagLink *hashtagLink in hashtags) {
        MBTextIndex *index = hashtagLink.textIndex;
        [attributedString addAttributes:@{NSLinkAttributeName: hashtagLink, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, index.end - index.begin)];
    }
    
    // Mention
    NSArray *mentionUsers = entity.userMentions;
    for (MBMentionUserLink *mentionLink in mentionUsers) {
        MBTextIndex *index = mentionLink.textIndex;
        [attributedString addAttributes:@{NSLinkAttributeName: mentionLink, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, index.end - index.begin)];
    }
    
    // media
    NSArray *media = entity.media;
    for (MBMediaLink *mediaLink in media.reverseObjectEnumerator) {
        MBTextIndex *index = mediaLink.textIndex;
        
        // check surrogatePair
        NSInteger begin = index.begin;
        NSInteger end = index.end;
        
        for (NSInteger i = 0; i < begin; i ++) {
            unichar c = [tweetText characterAtIndex:i];
            if (CFStringIsSurrogateHighCharacter(c)) {
                begin++;
                end++;
            }
        }
        
        for (NSInteger i = begin; i < end; i++) {
            unichar c = [tweetText characterAtIndex:i];
            if (CFStringIsSurrogateHighCharacter(c)) {
                end++;
            }
        }
        
        NSString *replaceString = mediaLink.displayText;
        
        [attributedString replaceCharactersInRange:NSMakeRange(begin, end - begin) withString:replaceString];
        [attributedString addAttributes:@{NSLinkAttributeName: mediaLink, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, replaceString.length)];
    }
    
    // URL
    NSArray *urls = entity.urls;
    for (MBURLLink *urlLink in urls.reverseObjectEnumerator) {
        
        MBTextIndex *index = urlLink.textIndex;
        
        // check surrogatePair
        NSInteger begin = index.begin;
        NSInteger end = index.end;
        
        for (NSInteger i = 0; i < begin; i ++) {
            unichar c = [tweetText characterAtIndex:i];
            if (CFStringIsSurrogateHighCharacter(c)) {
                begin++;
                end++;
            }
        }
        
        for (NSInteger i = begin; i < end; i++) {
            unichar c = [tweetText characterAtIndex:i];
            if (CFStringIsSurrogateHighCharacter(c)) {
                end++;
            }
        }
        
        NSString *replaceString = urlLink.displayText;
        [attributedString replaceCharactersInRange:NSMakeRange(begin, end - begin) withString:replaceString];
        [attributedString addAttributes:@{NSLinkAttributeName: urlLink, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, replaceString.length)];
    }
    
    // 特殊文字
    NSDictionary *refs = @{@"&amp;": @"&", @"&lt;": @"<", @"&gt;": @">", @"&quot;": @"\"", @"&apos;": @"'"};
    for (NSString *key in refs.allKeys.reverseObjectEnumerator) {
        NSRange range = [attributedString.string rangeOfString:key];
        while (range.location != NSNotFound) {
            [attributedString replaceCharactersInRange:range withString:refs[key]];
            range = [attributedString.string rangeOfString:key];
        }
    }
    
    return attributedString;
}

@end

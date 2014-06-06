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
    return [self attributedStringForTweet:tweet tintColor:nil];
}

+ (NSAttributedString *)attributedStringForTweet:(MBTweet *)tweet tintColor:(UIColor *)tintColor
{
    if (nil == tweet) {
        return [[NSAttributedString alloc] init];
    }
    UIColor *linkTextColor = tintColor;
    if (nil == tintColor) {
        linkTextColor = [UIColor blueColor];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    
    UIColor *defaultTextColor = [UIColor blackColor];
    
    
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
        [attributedString addAttributes:@{NSLinkAttributeName: mediaLink.expandedURLText, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, replaceString.length)];
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
        [attributedString addAttributes:@{NSLinkAttributeName: urlLink.expandedURLText, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, replaceString.length)];
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

+ (NSAttributedString *)attributedStringForUser:(MBUser *)user linkColor:(UIColor *)linkColor
{
    if (nil == user) {
        return [[NSAttributedString alloc] init];
    }
    UIColor *linkTextColor = linkColor;
    if (nil == linkColor) {
        linkTextColor = [UIColor blueColor];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    
    UIColor *defaultTextColor = [UIColor blackColor];
    
    
    NSString *tweetText = user.desctiprion;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tweetText attributes:@{(id)kCTForegroundColorAttributeName: (id)defaultTextColor, (id)kCTFontAttributeName: (__bridge id)fontRef}];
    CFRelease(fontRef);
    
    
    MBEntity *entity = user.entity;
    
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
        [attributedString addAttributes:@{NSLinkAttributeName: mediaLink.expandedURLText, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, replaceString.length)];
    }
    /*
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
        [attributedString addAttributes:@{NSLinkAttributeName: urlLink.expandedURLText, (id)kCTForegroundColorAttributeName: (id)linkTextColor} range:NSMakeRange(index.begin, replaceString.length)];
    }*/
    
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

+ (NSAttributedString *)attributedStringForTimelineDate:(NSString *)dateString font:(UIFont *)font screeName:(NSString *)screenName tweetID:(unsigned long long)tweetID
{
    if (nil == dateString|| nil == screenName || 0 == tweetID) {
        return [[NSAttributedString alloc] init];
    }
    UIColor *textColor = [UIColor lightGrayColor];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSString *tweetURL = [NSString stringWithFormat:@"https://twitter.com/%@/status/%lld", screenName, tweetID];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:dateString attributes:@{(id)kCTForegroundColorAttributeName: textColor, (id)kCTFontAttributeName: (__bridge id)fontRef, NSLinkAttributeName : tweetURL}];
    CFRelease(fontRef);
    
    return attributedString;
}

+ (NSAttributedString *)attributedStringForDetailTweetDate:(NSString *)dateString font:(UIFont *)font screeName :(NSString *)screenName tweetID:(unsigned long long)tweetID
{
    if (nil == dateString) {
        return [[NSAttributedString alloc] init];
    }
    
    UIColor *textColor = [UIColor lightGrayColor];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSString *tweetURL = [NSString stringWithFormat:@"https://twitter.com/%@/status/%lld", screenName, tweetID];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:dateString attributes:@{(id)kCTForegroundColorAttributeName: textColor, (id)kCTFontAttributeName: (__bridge id)fontRef, NSLinkAttributeName: tweetURL}];
    CFRelease(fontRef);
    
    return attributedString;
}

@end

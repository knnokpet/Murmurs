//
//  MBProfileDesciptionView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBTweetTextView;
@interface MBProfileDesciptionView : UIView

@property (nonatomic, readonly) MBTweetTextView *textView;
@property (nonatomic, readonly) NSAttributedString *attributedString;
- (void)setAttributedString:(NSAttributedString *)attributedString;

@end

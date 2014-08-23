//
//  MBProfileDesciptionView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBProfileDesciptionView.h"
#import "MBTweetTextView.h"

@implementation MBProfileDesciptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureView:frame];
    }
    return self;
}

- (void)configureView:(CGRect)frame
{
    _textView = [[MBTweetTextView alloc] initWithFrame:frame];
    self.textView.alignment = NSTextAlignmentCenter;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textView];
}

#pragma mark -Setter & Getter
- (void)setAttributedString:(NSAttributedString *)attributedString
{
    _attributedString = attributedString;
    if (0 < attributedString.length) {
        CGRect textFrame = [MBTweetTextView frameRectWithAttributedString:attributedString constraintSize:self.bounds.size lineSpace:4.0f font:[UIFont systemFontOfSize:14.0f]];
        CGRect descriptionFrame = self.textView.frame;
        descriptionFrame.size = textFrame.size;
        self.textView.frame = descriptionFrame;
        self.textView.font = [UIFont systemFontOfSize:14.0f];
        self.textView.lineSpace = 4.0f;
        self.textView.lineHeight = 0.0f;
        self.textView.paragraphSpace = 0.0f;
        self.textView.attributedString = attributedString;
        [self setNeedsDisplay];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textFrame = self.textView.frame;
    textFrame.origin.x = self.bounds.size.width / 2 - self.textView.frame.size.width / 2;
    textFrame.origin.y = self.bounds.size.height / 2 - self.textView.frame.size.height / 2;
    self.textView.frame = textFrame;
}

@end

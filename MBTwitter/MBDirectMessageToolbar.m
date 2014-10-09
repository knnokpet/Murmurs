//
//  MBDirectMessageToolbar.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDirectMessageToolbar.h"

@implementation MBDirectMessageToolbar
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        defaultToolBarSize = frame.size;
        [self configureButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame maxSpace:(CGFloat)space
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxSpace = space;
        defaultToolBarSize = frame.size;
        [self configureButton];
    }
    
    return self;
}

- (void)setTextViewText:(NSString *)textViewText
{
    self.textView.text = textViewText;
    [self changeFrame];
    [self enableSendButton];
}

- (void)setMaxSpace:(CGFloat)maxSpace
{
    _maxSpace = maxSpace;
}

- (void)configureButton
{
    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStyleDone target:nil action:nil];
    self.sendButton.enabled = NO;
    
    defaultTextViewSize = CGSizeMake(self.bounds.size.width - 100, 36);
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, defaultTextViewSize.width, defaultTextViewSize.height)];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.layer.borderWidth = 0.5f;
    CGColorRef lineColorRef = CGColorCreateCopyWithAlpha([UIColor lightGrayColor].CGColor, 0.5);
    self.textView.layer.borderColor = lineColorRef;
    CGColorRelease(lineColorRef);
    self.textView.font = [UIFont systemFontOfSize:17.0f];
    self.textView.scrollEnabled = NO;
    UIBarButtonItem *textBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.textView];
    [self setItems:@[self.cameraButton, textBarItem, self.sendButton]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)enableSendButton
{
    if (self.textView.text.length > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
}

- (void)changeFrame
{
    CGFloat barItemMargin = 3.0f;
    
    UITextView *sizingTextView = [[UITextView alloc] init];
    sizingTextView.attributedText = self.textView.attributedText;
    CGSize textSize = [sizingTextView sizeThatFits:CGSizeMake(defaultTextViewSize.width, CGFLOAT_MAX)];
    
    CGFloat toolbarHeight = textSize.height + barItemMargin * 2;
    CGFloat textHeight = textSize.height;
    if (toolbarHeight < defaultToolBarSize.height) {
        toolbarHeight = defaultToolBarSize.height;
        textHeight = defaultTextViewSize.height;
    }
    if (toolbarHeight > self.maxSpace) {
        toolbarHeight = self.maxSpace;
        textHeight = self.maxSpace - barItemMargin * 2;
        self.textView.scrollEnabled = YES;
    } else {
        self.textView.scrollEnabled = NO;
    }
    
    CGRect textRect = self.textView.frame;
    textRect.size.height = textHeight;
    self.textView.frame = textRect;
    
    CGRect selfRect = self.frame;
    selfRect.size.height = toolbarHeight;
    self.frame = selfRect;
    
    for (NSLayoutConstraint *constraint in self.inputAccessoryView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            [constraint setConstant:toolbarHeight];
            break;
        }
    }
}

#pragma mark UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self changeFrame];
    [self enableSendButton];
    
    if ([_toolbarDelegate respondsToSelector:@selector(toolbarDidChangeText:)]) {
        [_toolbarDelegate toolbarDidChangeText:self];
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeZero;
}

@end

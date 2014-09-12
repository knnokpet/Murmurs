//
//  MBPlaceHolderTextView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBPlaceHolderTextView.h"

@interface MBPlaceHolderTextView()

@property (nonatomic) UILabel *placeHolderLabel;

@end



@implementation MBPlaceHolderTextView
- (void)awakeFromNib
{
    [self commonInit];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    CGFloat labelMargin = 8.0f;
    _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMargin / 2, labelMargin, self.bounds.size.width - labelMargin , 0)];
    self.placeHolder = @"";
    self.placeHolderColor = [UIColor lightGrayColor];
    self.placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.placeHolderLabel.numberOfLines = 0;
    self.placeHolderLabel.font = self.font;
    self.placeHolderLabel.backgroundColor = [UIColor clearColor];
    self.placeHolderLabel.alpha = 0;
    [self addSubview:self.placeHolderLabel];
    
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    self.placeHolderLabel.text = placeHolder;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor = placeHolderColor;
    self.placeHolderLabel.textColor = placeHolderColor;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textDidChange:nil];
}

- (void)textDidChange:(NSNotification *)notification
{
    if (self.placeHolder.length == 0) {
        return;
    }
    
    self.placeHolderLabel.alpha = (self.text.length == 0) ? 1 : 0;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    
    if (self.placeHolderLabel.text.length > 0) {
        [self.placeHolderLabel sizeToFit];
        [self sendSubviewToBack:self.placeHolderLabel];
    }
    NSLog(@"%@", self.placeHolder);
    if (self.text.length == 0 && self.placeHolder.length > 0) {
        self.placeHolderLabel.alpha = 1.0;
    }
    
    [super drawRect:rect];
}


@end

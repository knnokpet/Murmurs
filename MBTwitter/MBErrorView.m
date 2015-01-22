//
//  MBErrorView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/06.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import "MBErrorView.h"

#define maxWidth 200
#define imageWidth 100

@implementation MBErrorView

- (instancetype)initWithErrorText:(NSString *)errorText
{
    self = [super init];
    if (self) {
        [self commonInit];
        [self configureTextViewWithText:errorText];
    }
    return self;
}

- (void)commonInit
{
    self.layer.cornerRadius = 16.0f;
    self.backgroundColor = [UIColor blackColor];
    self.userInteractionEnabled = NO;
    self.alpha = 0.8;
}

- (void)configureTextViewWithText:(NSString *)errorText
{
    
    UITextView *errorTextView = [[UITextView alloc] init];
    errorTextView.backgroundColor = [UIColor clearColor];
    errorTextView.textAlignment = NSTextAlignmentCenter;
    errorTextView.font = [UIFont boldSystemFontOfSize:17.0];
    errorTextView.textColor = [UIColor whiteColor];
    errorTextView.text = errorText;
    CGSize textViewSize = [errorTextView sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    
    UIImageView *errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Error"]];
    [self addSubview:errorImageView];
    
    NSInteger margin = 4.0;
    CGRect myFrame = CGRectZero;
    myFrame.size.width = textViewSize.width + margin * 2;
    myFrame.size.height = textViewSize.height + errorImageView.bounds.size.height + margin * 2;
    self.frame = myFrame;
    
    CGRect errorViewFrame = errorImageView.frame;
    errorViewFrame.origin.x = floorf(myFrame.size.width / 2 - errorViewFrame.size.width / 2);
    errorViewFrame.origin.y = margin;
    errorImageView.frame = errorViewFrame;
    
    [self addSubview:errorTextView];
    errorTextView.frame = CGRectMake(floorf(myFrame.size.width / 2 - textViewSize.width / 2), floorf(myFrame.size.height) - textViewSize.height - margin, textViewSize.width, textViewSize.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

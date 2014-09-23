//
//  MBProtectedUserDetailView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBProtectedUserDetailView.h"

@interface MBProtectedUserDetailView ()
{
    CGSize maxOperationSize;
    CGSize maxDetailSize;
}

@end

@implementation MBProtectedUserDetailView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    _protectedIamgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.protectedIamgeView.image = [UIImage imageNamed:@"SentRequest"];
    [self addSubview:self.protectedIamgeView];
    
    maxOperationSize = CGSizeMake(226, 58);
    maxDetailSize = CGSizeMake(240, 66);
    
    _operationTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, maxOperationSize.width, maxOperationSize.height)];
    [self insertSubview:self.operationTextView aboveSubview:self.protectedIamgeView];
    self.operationTextView.font = [UIFont boldSystemFontOfSize:20.0f];
    CGFloat red, green, blue, alp;
    red = green = blue = 0.329;
    alp = 1.0;
    self.operationTextView.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alp];
    self.operationTextView.backgroundColor = [UIColor clearColor];
    //self.operationTextView.scrollEnabled = NO;
    self.operationTextView.bounces = NO;
    self.operationTextView.editable = NO;
    self.operationTextView.selectable = NO;
    
    _detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, maxDetailSize.width, maxDetailSize.height)];
    [self insertSubview:self.detailTextView aboveSubview:self.protectedIamgeView];
    self.detailTextView.font = [UIFont systemFontOfSize:14.0f];
    red = green = blue = 0.329;
    self.detailTextView.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alp];
    self.detailTextView.backgroundColor = [UIColor clearColor];
    //self.detailTextView.scrollEnabled = NO;
    self.detailTextView.bounces = NO;
    self.detailTextView.editable = NO;
    self.detailTextView.selectable = NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setOperationString:(NSString *)operationString
{
    _operationString = operationString;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:operationString];
    NSRange range = NSMakeRange(0, attributedString.length);
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [shadow setShadowBlurRadius:6.0];
    [shadow setShadowOffset:CGSizeMake(0, 2)];
    [attributedString addAttribute:NSShadowAttributeName value:shadow range:range];
    [attributedString addAttribute:NSFontAttributeName value:self.operationTextView.font range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.operationTextView.textColor range:range];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    
    self.operationTextView.attributedText = attributedString;
    
    [self setNeedsLayout];
}

- (void)setDetailString:(NSString *)detailString
{
    _detailString = detailString;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:detailString];
    NSRange range = NSMakeRange(0, attributedString.length);
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [shadow setShadowBlurRadius:6.0];
    [shadow setShadowOffset:CGSizeMake(0, 2)];
    [attributedString addAttribute:NSShadowAttributeName value:shadow range:range];
    [attributedString addAttribute:NSFontAttributeName value:self.detailTextView.font range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.detailTextView.textColor range:range];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    
    self.detailTextView.attributedText = attributedString;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    CGRect operationRect = self.operationTextView.frame;
    operationRect.origin = CGPointMake(center.x - operationRect.size.width / 2, center.y - operationRect.size.height);
    self.operationTextView.frame = operationRect;
    
    CGRect detailRect = self.detailTextView.frame;
    detailRect.origin = CGPointMake(center.x - detailRect.size.width / 2, center.y);
    self.detailTextView.frame = detailRect;
}

@end

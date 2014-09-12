//
//  MBGapedTweetViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/25.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBGapedTweetViewCell.h"

@implementation MBGapedTweetViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self common];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self common];
}

- (void)common
{
    [self.gapButton setTitle:NSLocalizedString(@"Loading Gapped Tweet", nil) forState:UIControlStateNormal];
    [self.gapButton setTitle:NSLocalizedString(@"Now Loading...", nil) forState:UIControlStateDisabled];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hittedView = [super hitTest:point withEvent:event];
    
    if (hittedView == self.gapButton) {
        return hittedView;
    }
    
    return nil;
}

@end

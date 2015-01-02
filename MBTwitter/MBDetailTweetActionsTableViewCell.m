//
//  MBDetailTweetActionsTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetActionsTableViewCell.h"
#import "MBTitleWithImageButton.h"

@implementation MBDetailTweetActionsTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hittedView = [super hitTest:point withEvent:event];
    if (hittedView == self) {
        return nil;
    } else if (hittedView == self.contentView) {
        return nil;
    }
    
    return hittedView;
}

@end

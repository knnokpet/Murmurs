//
//  MBDetailUserTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailUserTableViewCell.h"

@implementation MBDetailUserTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark -Setter & Getter
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCanMessage:(BOOL)canMessage
{
    _canMessage = canMessage;
    self.MessageButton.enabled = canMessage;
    
    [self setNeedsDisplay];
}

- (void)setCanFollow:(BOOL)canFollow
{
    _canFollow = canFollow;
    
    if (canFollow) {
        self.followButton.enabled = YES;
        self.followButton.titleLabel.text = NSLocalizedString(@"Follow", nil);
        self.followButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        
    } else {
        self.followButton.enabled = NO;
        self.followButton.titleLabel.text = NSLocalizedString(@"Now Following", nil);
        self.followButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    
    [self setNeedsDisplay];
}

@end

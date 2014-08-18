//
//  MBMyAccountsTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBMyAccountsTableViewCell.h"

@implementation MBMyAccountsTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.avatorImageView.layer.cornerRadius = 4.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  MBSeparatedDirectMessageUserTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/04/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSeparatedDirectMessageUserTableViewCell.h"

@implementation MBSeparatedDirectMessageUserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    self.iconImageView.backgroundColor = [UIColor clearColor];
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 4.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    if (0 < screenName.length) {
        NSString *nameAtmark = [NSString stringWithFormat:@"@%@", screenName];
        self.screenNameLabel.text = nameAtmark;
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.characterNameLabel sizeToFit];
    [self.screenNameLabel sizeToFit];
    CGFloat namesSpace = (self.dateLabel.frame.origin.x - self.characterNameLabel.frame.origin.x);
    if (namesSpace < self.characterNameLabel.frame.size.width + self.screenNameLabel.frame.size.width) {
        CGRect screenFrame = self.screenNameLabel.frame;
        CGFloat screenWidth = namesSpace - self.characterNameLabel.frame.size.width;
        if (screenWidth < 0) {
            screenWidth = 0.0f;
        }
        screenFrame.size.width = screenWidth;
        self.screenNameLabel.frame = screenFrame;
    }
    CGRect screenFrame = self.screenNameLabel.frame;
    screenFrame.origin.x = self.characterNameLabel.frame.origin.x + self.characterNameLabel.frame.size.width + 8;
    self.screenNameLabel.frame = screenFrame;
    
    if ( namesSpace < self.characterNameLabel.frame.size.width) {
        CGRect characterFrame = self.characterNameLabel.frame;
        characterFrame.size.width = (self.dateLabel.frame.origin.x - self.characterNameLabel.frame.origin.x - 8);
        self.characterNameLabel.frame = characterFrame;
        
        CGRect screenFrame = self.screenNameLabel.frame;
        screenFrame.size.width = 0.f;
        self.screenNameLabel.frame = screenFrame;
    }
}

@end

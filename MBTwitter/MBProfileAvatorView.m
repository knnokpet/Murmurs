//
//  MBProfileAvatorView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBProfileAvatorView.h"

#import "MBAvatorImageView.h"

@interface MBProfileAvatorView()
@property (nonatomic) UIView *containAvatorImageView;

@end

@implementation MBProfileAvatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    self.containAvatorImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    self.containAvatorImageView.backgroundColor = [UIColor whiteColor];
    CGRect containerFrame = self.containAvatorImageView.frame;
    containerFrame.origin.x = self.frame.size.width / 2 - self.containAvatorImageView.frame.size.width / 2;
    containerFrame.origin.y = 16;
    self.containAvatorImageView.frame = containerFrame;
    self.containAvatorImageView.layer.cornerRadius = 8.0f;
    [self addSubview:self.containAvatorImageView];
    
    self.avatorImageView = [[MBAvatorImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
    CGRect avatorFrame = self.avatorImageView.frame;
    avatorFrame.origin.x = self.containAvatorImageView.frame.size.width / 2 - self.avatorImageView.frame.size.width / 2;
    avatorFrame.origin.y = self.containAvatorImageView.frame.size.height / 2 - self.avatorImageView.frame.size.height / 2;
    self.avatorImageView.frame = avatorFrame;
    self.avatorImageView.layer.cornerRadius = 8.0f;
    [self.containAvatorImageView addSubview:self.avatorImageView];
    
    self.characterNameLabel = [[UILabel alloc] init];
    self.characterNameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.characterNameLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.characterNameLabel];
    
    self.screenNameLabel = [[UILabel alloc] init];
    self.screenNameLabel.font = [UIFont systemFontOfSize:15.0f];
    self.screenNameLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.screenNameLabel];
}

- (void)setCharacterName:(NSString *)characterName
{
    _characterName = characterName;
    self.characterNameLabel.text = characterName;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    if (0 < screenName.length) {
        NSString *screenNameAt = [NSString stringWithFormat:@"@%@", screenName];
        self.screenNameLabel.text = screenNameAt;
        [self setNeedsDisplay];
        [self setNeedsLayout];
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
    [self.characterNameLabel sizeToFit];
    [self.screenNameLabel sizeToFit];
    CGRect labelFrame = self.characterNameLabel.frame;
    labelFrame.origin.x = self.frame.size.width / 2 - self.characterNameLabel.frame.size.width / 2;
    labelFrame.origin.y = self.containAvatorImageView.frame.origin.y + self.containAvatorImageView.frame.size.height + 4;
    self.characterNameLabel.frame = labelFrame;
    
    CGRect screenLabelFrame = self.screenNameLabel.frame;
    screenLabelFrame.origin.x = self.frame.size.width / 2 - self.screenNameLabel.frame.size.width / 2;
    screenLabelFrame.origin.y = self.characterNameLabel.frame.origin.y + self.characterNameLabel.frame.size.height + 4;
    self.screenNameLabel.frame = screenLabelFrame;
}

@end

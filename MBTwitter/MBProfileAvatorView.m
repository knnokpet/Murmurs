//
//  MBProfileAvatorView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/01.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBProfileAvatorView.h"

#import "MBAvatorImageView.h"
#import "MBShadowBlurLabel.h"

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
    CGRect containerFrame = self.containAvatorImageView.frame;
    containerFrame.origin.x = ceilf(self.frame.size.width / 2 - self.containAvatorImageView.frame.size.width / 2);
    containerFrame.origin.y = 16;
    self.containAvatorImageView.frame = containerFrame;
    self.containAvatorImageView.layer.cornerRadius = 8.0f;
    //self.containAvatorImageView.layer.borderWidth = 0.5f;
    //self.containAvatorImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    self.containAvatorImageView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self addSubview:self.containAvatorImageView];
    
    self.avatorImageView = [[MBAvatorImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
    CGRect avatorFrame = self.avatorImageView.frame;
    avatorFrame.origin.x = ceilf(self.containAvatorImageView.frame.size.width / 2 - self.avatorImageView.frame.size.width / 2);
    avatorFrame.origin.y = ceilf(self.containAvatorImageView.frame.size.height / 2 - self.avatorImageView.frame.size.height / 2);
    self.avatorImageView.frame = avatorFrame;
    self.avatorImageView.layer.cornerRadius = 8.0f;
    [self.containAvatorImageView addSubview:self.avatorImageView];
    
    self.characterNameLabel = [[MBShadowBlurLabel alloc] init];
    self.characterNameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.characterNameLabel.textColor = [UIColor whiteColor];
    self.characterNameLabel.textAlignment = NSTextAlignmentCenter;
    self.characterNameLabel.layer.cornerRadius = 10.0f;
    [self addSubview:self.characterNameLabel];
    
    self.screenNameLabel = [[MBShadowBlurLabel alloc] init];
    self.screenNameLabel.font = [UIFont systemFontOfSize:15.0f];
    self.screenNameLabel.textColor = [UIColor whiteColor];
    self.screenNameLabel.textAlignment = NSTextAlignmentCenter;
    self.screenNameLabel.layer.cornerRadius = 8.0f;
    [self addSubview:self.screenNameLabel];
    
    self.protectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Lock-mini-1-white"]];
    [self setIsProtected:NO];
    [self addSubview:self.protectImageView];
    
    self.verifiedIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VerifiedBadge"]];
    [self addSubview:self.verifiedIconImageView];
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

- (void)setIsProtected:(BOOL)isProtected
{
    _isProtected = isProtected;
    
    BOOL isHidden = (isProtected) ? NO : YES;
    self.protectImageView.hidden = isHidden;
    
    [self setNeedsLayout];
}

- (void)setIsVerified:(BOOL)isVerified
{
    _isVerified = isVerified;
    if (!isVerified) {
        [self.verifiedIconImageView removeFromSuperview];
    } else {
        if (!self.verifiedIconImageView.superview) {
            [self addSubview:self.verifiedIconImageView];
        }
    }
    
    [self setNeedsLayout];
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
    
    CGFloat horizontalMargin = 2.0f;
    CGFloat verticalMargin = 1.0f;
    
    [self.characterNameLabel sizeToFit];
    [self.screenNameLabel sizeToFit];
    
    
    // characterNameLabel
    CGRect labelFrame = self.characterNameLabel.frame;
    labelFrame.size.width += horizontalMargin * 2;
    labelFrame.size.height += verticalMargin * 2;
    labelFrame.origin.x = self.frame.size.width / 2 - labelFrame.size.width / 2;
    labelFrame.origin.y = self.containAvatorImageView.frame.origin.y + self.containAvatorImageView.frame.size.height + 4;
    self.characterNameLabel.frame = labelFrame;
    
    // verified badge
    CGRect badgeRect = self.verifiedIconImageView.frame;
    badgeRect.origin = CGPointMake(labelFrame.origin.x + labelFrame.size.width + verticalMargin, (labelFrame.origin.y + labelFrame.size.height / 2) - (badgeRect.size.height / 2));
    self.verifiedIconImageView.frame = badgeRect;
    
    // screenNameLabel
    CGRect screenLabelFrame = self.screenNameLabel.frame;
    screenLabelFrame.size.width += horizontalMargin * 2;
    screenLabelFrame.size.height += verticalMargin * 2;
    screenLabelFrame.origin.x = self.frame.size.width / 2 - screenLabelFrame.size.width / 2;
    screenLabelFrame.origin.y = self.characterNameLabel.frame.origin.y + self.characterNameLabel.frame.size.height;
    self.screenNameLabel.frame = screenLabelFrame;

    // protectedImageView
    CGRect protectedImageViewRect = self.protectImageView.frame;
    protectedImageViewRect.origin.x = self.screenNameLabel.frame.origin.x + self.screenNameLabel.frame.size.width + horizontalMargin;
    protectedImageViewRect.origin.y = (self.screenNameLabel.frame.origin.y + self.screenNameLabel.frame.size.height / 2) - (self.protectImageView.bounds.size.height / 2);
    self.protectImageView.frame = protectedImageViewRect;
}

#pragma mark - Instance Methods
- (void)addAvatorImage:(UIImage *)image animated:(BOOL)animated
{
    NSInteger duration = (animated) ? 0.3f : 0;
    self.avatorImageView.alpha = 0.0f;
    self.avatorImageView.avatorImage = image;
    [UIView animateWithDuration:duration animations:^{
        self.avatorImageView.alpha = 1.0f;
    }];
}

@end

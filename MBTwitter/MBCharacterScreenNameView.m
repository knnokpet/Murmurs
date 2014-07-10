//
//  MBCharacterScreenNameView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/10.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBCharacterScreenNameView.h"

@implementation MBCharacterScreenNameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCharacterScreenString:(NSAttributedString *)characterScreenString
{
    _characterScreenString = characterScreenString;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
    [self.characterScreenString drawInRect:rect];
}


@end

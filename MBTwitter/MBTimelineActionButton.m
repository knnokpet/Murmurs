//
//  MBTimelineActionButton.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineActionButton.h"

@implementation MBTimelineActionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image
{
    self = [super init];
    if (self) {
        _title = title;
        _image = [image imageWithMaskColor:[UIColor whiteColor]];
        self.frame = CGRectMake(0, 0, 80, 40);
        self.backgroundColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        [self setTitle:self.title forState:UIControlStateNormal];
        //[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setImage:self.image forState:UIControlStateNormal];
        
        [self setTitle:self.title forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setImage:self.image forState:UIControlStateHighlighted];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor clearColor];
    } else {
        
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame = CGRectMake(0, self.bounds.size.height - titleFrame.size.height, self.bounds.size.width, titleFrame.size.height);
    self.titleLabel.frame = titleFrame;
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.size = self.image.size;
    imageFrame = CGRectMake(truncf((self.bounds.size.width - imageFrame.size.width) / 2), self.titleLabel.frame.origin.y - imageFrame.size.height, imageFrame.size.width, imageFrame.size.height);
    self.imageView.frame = imageFrame;
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
    [[UIColor blackColor] setStroke];
    if (self.selected) {
        [[UIColor clearColor] setFill];
    }
    
    CGRect bounds = self.bounds;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(bounds.origin.x + bounds.size.width / 2, bounds.origin.y + bounds.size.height, bounds.size.width, bounds.size.height)];
    [bezierPath stroke];
    [bezierPath fill];
}*/
/* ボタン内で弄るとボタン特有の動きがなくなる
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor greenColor];
}*/

@end

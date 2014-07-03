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
        _image = image;
        self.frame = CGRectMake(0, 0, 80, 50);
        //self.backgroundColor = [UIColor blackColor];
        
        [self setTitle:self.title forState:UIControlStateNormal];
        //[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self setImage:self.image forState:UIControlStateNormal];
        
        [self setTitle:self.title forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
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
        //self.backgroundColor = [UIColor greenColor];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame = CGRectMake(truncf((self.bounds.size.width - imageFrame.size.width) / 2), 0.0f, imageFrame.size.width, imageFrame.size.height);
    self.imageView.frame = imageFrame;
    
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame = CGRectMake(trunc((self.bounds.size.width - titleFrame.size.width) / 2), self.bounds.size.height - titleFrame.size.height, titleFrame.size.width, titleFrame.size.height);
    self.titleLabel.frame = titleFrame;
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
/*
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

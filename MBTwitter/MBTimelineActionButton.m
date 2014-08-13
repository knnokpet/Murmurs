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
        self.frame = CGRectMake(0, 0, 80, 44);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        // normal state
        [self setTitle:self.title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setImage:self.image forState:UIControlStateNormal];
        
        // highlighte state
        [self setTitle:self.title forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self setImage:self.image forState:UIControlStateHighlighted];
        
        // disabled state
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat verticalMargin = 4.0f;
    
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin = CGPointMake(center.x - imageFrame.size.width / 2, center.y - imageFrame.size.height);
    self.imageView.frame = imageFrame;
    
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin = CGPointMake(center.x - titleFrame.size.width / 2, center.y);
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
/* ボタン内で弄るとボタン特有の動きがなくなる*
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
    self.highlighted = YES;
}*/

@end

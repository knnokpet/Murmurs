//
//  MBTimelineActionButton.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTimelineActionButton.h"

@interface MBTimelineActionButton()

@property (nonatomic, readonly) UIColor *defaultBackgroundColor;
@property (nonatomic, readonly) UIColor *selectedBackgroundColor;

@end

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
        _defaultBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
        _selectedBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        // normal state
        [self setTitle:self.title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setImage:self.image forState:UIControlStateNormal];
        
        // highlighte state
        [self setTitle:self.title forState:UIControlStateSelected | UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self setImage:self.image forState:UIControlStateSelected | UIControlStateHighlighted];
        
        // disabled state
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        
        [self addTarget:self action:@selector(touchBegan:withEvent:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(touchCanceled:withEvent:) forControlEvents:UIControlEventTouchDragOutside | UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(touchEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
    
    if ([_delegate respondsToSelector:@selector(timelineActionButton:isSelected:)]) {
        [_delegate timelineActionButton:self isSelected:selected];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(ceilf(bounds.size.width / 2), ceilf(bounds.size.height / 2));
    CGFloat topMargin = 2.0f;
    
    [self.imageView sizeToFit];
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin = CGPointMake(ceilf(center.x - imageFrame.size.width / 2), ceilf(center.y - imageFrame.size.height) + topMargin);
    self.imageView.frame = imageFrame;

    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin = CGPointMake(ceilf(center.x - titleFrame.size.width / 2), ceilf(center.y + topMargin));
    self.titleLabel.frame = titleFrame;

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef filledColorRef;
    
    if (self.selected) {
        filledColorRef = CGColorCreateCopy(self.selectedBackgroundColor.CGColor);
        
    } else {
        filledColorRef = CGColorCreateCopy(self.defaultBackgroundColor.CGColor);
    }
    
    CGContextSetFillColorWithColor(context, filledColorRef);
    CGContextFillRect(context, rect);
    CGColorRelease(filledColorRef);
    
}

- (void)touchBegan:(UIButton *)control withEvent:(UIEvent *)event
{
    self.selected = YES;
    self.highlighted = YES;
}

- (void)touchMoving:(UIButton *)control withEvent:(UIEvent *)event
{
    self.selected = YES;
    self.highlighted = YES;
}

- (void)touchCanceled:(UIButton *)control withEvent:(UIEvent *)event
{
    self.selected = NO;
    self.highlighted = NO;
}

- (void)touchEnded:(UIButton *)control withEvent:(UIEvent *)event
{
    self.selected = YES;
}

@end

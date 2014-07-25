//
//  MBGeoPinView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/21.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBGeoPinView.h"

@interface MBDotView : UIView

@property (nonatomic) UIColor *dotColor;

@end


@implementation MBDotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self.dotColor set];
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [dotPath fill];
}

@end



@interface MBGeoPinView()

@property (nonatomic, readonly) MBDotView *dotView;
@property (nonatomic, readonly) UIView *hogeView;

@end

@implementation MBGeoPinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _dotView = [[MBDotView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        CGPoint dotPoint = CGPointMake(self.frame.size.width / 2 - self.dotView.frame.size.width / 2, 0);
        CGRect dotRect = self.dotView.frame;
        dotRect.origin = dotPoint;
        self.dotView.frame = dotRect;
        [self addSubview:self.dotView];
        
        CGFloat hogeWidth = 2.0f;
        CGFloat hogeOriginY = self.dotView.frame.origin.y + self.dotView.frame.size.height;
        CGRect hogeRect = CGRectMake(self.frame.size.width / 2 - hogeWidth / 2, hogeOriginY, hogeWidth, self.frame.size.height - hogeOriginY);
        _hogeView = [[UIView alloc] initWithFrame:hogeRect];
        self.hogeView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.hogeView];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
}

- (void)boundingAnimateDotWithCompletion:(CompletionHandler)completion
{
    CGRect endRect = self.dotView.frame;
    CGRect boundingRect = endRect;
    boundingRect.origin.y = boundingRect.origin.y + 4.0f;
    [UIView animateWithDuration:0.1f animations:^{
        self.dotView.frame = boundingRect;
        self.dotView.frame = endRect;
        
    }completion:^(BOOL finished) {
        completion();
    }];
}

- (void)scallingAnimateDotWithCompletion:(CompletionHandler)completion
{
    [UIView animateWithDuration:0.1f animations:^{
        self.dotView.transform = CGAffineTransformMakeScale(0.5, 2.0);
        self.dotView.transform = CGAffineTransformMakeScale(0, 0);
    }completion:^(BOOL finished) {
        completion();
    }];
}

- (void)contractView
{
    CGFloat endOriginY = self.hogeView.frame.origin.y + self.hogeView.frame.size.height;
    
    CGRect dotEndRect = self.dotView.frame;
    dotEndRect.origin.y = endOriginY - dotEndRect.size.height;
    self.dotView.frame = dotEndRect;
    
    CGRect pinRect = self.hogeView.frame;
    pinRect.origin.y = endOriginY;
    self.hogeView.frame = pinRect;
}

@end

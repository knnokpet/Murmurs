//
//  MBSelectionView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/05/17.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBSelectionView.h"
#import "MBSelectionGrabber.h"
#import "MBTweetTextView.h"

static const CGFloat MBSelectionGrabberWidth = 32.0f;

@interface MBTweetTextView (private)
- (void)selectionGestureStateChanged:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)grabberMoved:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@implementation MBSelectionView
- (instancetype)initWithFrame:(CGRect)frame tweetTextView:(MBTweetTextView *)textView
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.tweetTextView = textView;
        self.selectionGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self.tweetTextView action:@selector(selectionGestureStateChanged:)];
        [self addGestureRecognizer:self.selectionGestureRecognizer];
        
        
        self.startGrabber = [[MBSelectionGrabber alloc] init];
        self.startGrabber.dotMetric = MBSelectionGrabberDotMetricTop;
        [self addSubview:self.startGrabber];
        self.startGrabberGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.tweetTextView action:@selector(grabberMoved:)];
        [self.startGrabber addGestureRecognizer:self.startGrabberGestureRecognizer];
        
        
        self.endGrabber = [[MBSelectionGrabber alloc] init];
        self.endGrabber.dotMetric = MBSelectionGrabberDotMetricBottom;
        [self addSubview:self.endGrabber];
        self.endGrabberGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.tweetTextView action:@selector(grabberMoved:)];
        [self.endGrabber addGestureRecognizer:self.endGrabberGestureRecognizer];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateGrabbers
{
    CGRect startFrame = self.startFrame;
    startFrame.origin.x = CGRectGetMinX(self.startFrame) - MBSelectionGrabberWidth / 2;
    startFrame.size.width = MBSelectionGrabberWidth;
    self.startGrabber.frame = startFrame;
    
    CGRect endFrame = self.endFrame;
    endFrame.origin.x = CGRectGetMaxX(self.endFrame) - MBSelectionGrabberWidth / 2;
    endFrame.size.width = MBSelectionGrabberWidth;
    self.endGrabber.frame = endFrame;
    NSLog(@"start originx %f end %f", self.startGrabber.frame.origin.x, self.endGrabber.frame.origin.x);
}

- (void)showViews
{
    self.startGrabber.hidden = NO;
    self.endGrabber.hidden = NO;
}

- (void)hideViews
{
    self.startGrabber.hidden = YES;
    self.endGrabber.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

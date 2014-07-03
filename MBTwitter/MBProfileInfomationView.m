//
//  MBProfileInfomationView.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBProfileInfomationView.h"

@implementation MBProfileInfomationView

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
    self.locationTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    self.locationTextView.textAlignment = NSTextAlignmentCenter;
    self.locationTextView.textColor = [UIColor whiteColor];
    self.locationTextView.backgroundColor = [UIColor clearColor];
    self.locationTextView.editable = NO;
    [self addSubview:self.locationTextView];
    
    self.urlTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    self.urlTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.urlTextView.textAlignment = NSTextAlignmentCenter;
    self.urlTextView.textColor = [UIColor whiteColor];
    self.urlTextView.backgroundColor = [UIColor clearColor];
    self.urlTextView.editable = NO;
    [self addSubview:self.urlTextView];
}

- (void)setLocationText:(NSString *)locationText
{
    _locationText = locationText;
    if (0 < locationText.length) {
        self.locationTextView.text = locationText;
        [self setNeedsDisplay];
    }
}

- (void)setUrlText:(NSString *)urlText
{
    _urlText = urlText;
    if (0 < urlText.length) {
        self.urlTextView.text = urlText;
        [self setNeedsDisplay];
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
    NSLog(@"text %@ %@", self.locationTextView.text, self.urlTextView.text);
    [self.locationTextView sizeToFit];
    [self.urlTextView sizeToFit];
    
    if (0 == self.locationTextView.text.length) {
        self.urlTextView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
    }
    if (0 == self.urlTextView.text.length) {
        self.locationTextView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    if (0 < self.locationTextView.text.length && 0 < self.urlTextView.text.length) {
        CGRect bounds =  self.bounds;
        CGFloat margin = 4.0f;
        
        CGRect locationFrame = self.locationTextView.frame;
        locationFrame.origin.x = bounds.size.width / 2 - locationFrame.size.width / 2;
        locationFrame.origin.y = bounds.size.height / 2 - locationFrame.size.height - margin;
        self.locationTextView.frame = locationFrame;
        
        CGRect urlFrame = self.urlTextView.frame;
        urlFrame.origin.x = bounds.size.width / 2 - urlFrame.size.width / 2;
        urlFrame.origin.y = bounds.size.height / 2 + urlFrame.size.height + margin;
        self.urlTextView.frame = urlFrame;
    }
}

@end

//
//  MBTimelineActionButton.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/27.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBTimelineActionButtonDelegate;
@interface MBTimelineActionButton : UIButton

@property (nonatomic, weak) id <MBTimelineActionButtonDelegate> delegate;

@property (nonatomic) NSUInteger index;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *image;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

@end


@protocol MBTimelineActionButtonDelegate <NSObject>

- (void)timelineActionButton:(MBTimelineActionButton *)control isSelected:(BOOL)selected;

@end
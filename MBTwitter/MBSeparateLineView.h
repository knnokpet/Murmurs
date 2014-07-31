//
//  MBSeparateLineView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBSeparateLineView : UIView

@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;
- (void)setStartPoint:(CGPoint)startPoint;
- (void)setEndPoint:(CGPoint)endPoint;

@end

//
//  MBPlaceHolderTextView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBPlaceHolderTextView : UITextView

@property (nonatomic, readonly) NSString *placeHolder;
@property (nonatomic, readonly) UIColor *placeHolderColor;
- (void)setPlaceHolder:(NSString *)placeHolder;
- (void)setPlaceHolderColor:(UIColor *)placeHolderColor;

@end

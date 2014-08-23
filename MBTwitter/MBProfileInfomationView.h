//
//  MBProfileInfomationView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/06/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBProfileInfomationView : UIView

@property (nonatomic) UITextView *locationTextView;
@property (nonatomic) UITextView *urlTextView;

@property (nonatomic) NSString *locationText;
@property (nonatomic) NSString *urlText;
- (void)setLocationText:(NSString *)locationText;
- (void)setUrlText:(NSString *)urlText;

@end

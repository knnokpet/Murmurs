//
//  MBGeoPlaceView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/29.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBGeoPlaceView : UIView

@property (nonatomic, readonly) NSString *displayText;

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text;

@end

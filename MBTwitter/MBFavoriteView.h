//
//  MBFavoriteView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/24.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBFavoriteView : UIView

@property (nonatomic, readonly, assign) BOOL favorited;
@property (nonatomic, readonly, assign) BOOL geod;
- (void)setFavorited:(BOOL)favorited;
- (void)setGeod:(BOOL)geod;

@end

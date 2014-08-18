//
//  MBPlaceWithGeoIconView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/16.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBPlaceWithGeoIconView : UIView

@property (nonatomic, readonly) NSAttributedString *placeString;
- (void)setPlaceString:(NSAttributedString *)placeString;

@end

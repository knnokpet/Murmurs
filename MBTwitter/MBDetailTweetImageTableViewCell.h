//
//  MBDetailTweetImageTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/29.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailTweetImageTableViewCell : UITableViewCell

@property (nonatomic, readonly) UIImage *mediaImage;
- (void)setMediaImage:(UIImage *)mediaImage;

+ (CGFloat)heightWithImage:(UIImage *)image constraintSize:(CGSize)constraintSize;

@end

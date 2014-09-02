//
//  MBMediaImageView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/28.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBMediaImageViewDelegate;
@interface MBMediaImageView : UIImageView

@property (nonatomic, weak) id <MBMediaImageViewDelegate> delegate;

@property (nonatomic, readonly) NSString *mediaIDStr;
@property (nonatomic, readonly) NSString *mediaHTTPURLString;
@property (nonatomic, readonly) UIImage *mediaImage;
- (void)setMediaIDStr:(NSString *)mediaIDStr;
- (void)setMediaHTTPURLString:(NSString *)mediaHTTPURLString;
- (void)setMediaImage:(UIImage *)mediaImage;

@end


@protocol MBMediaImageViewDelegate <NSObject>

- (void)didTapImageView:(MBMediaImageView *)imageView mediaIDStr:(NSString *)mediaIDStr urlString:(NSString *)urlString touchedPoint:(CGPoint)touchedPoint rect:(CGRect)rect;

@end
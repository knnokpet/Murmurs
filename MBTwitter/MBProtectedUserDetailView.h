//
//  MBProtectedUserDetailView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/15.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBBlurView.h"

@interface MBProtectedUserDetailView : MBBlurView

@property (nonatomic, readonly) UIImageView *protectedIamgeView;

@property (nonatomic, readonly) UITextView *operationTextView;
@property (nonatomic, readonly) UITextView *detailTextView;

@property (nonatomic, readonly) NSString *operationString;
@property (nonatomic, readonly) NSString *detailString;
- (void)setOperationString:(NSString *)operationString;
- (void)setDetailString:(NSString *)detailString;

@end

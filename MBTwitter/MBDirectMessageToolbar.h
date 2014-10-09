//
//  MBDirectMessageToolbar.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/05.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBDirectMessageToolbarDelegate;
@interface MBDirectMessageToolbar : UIToolbar <UITextViewDelegate>
{
    CGSize defaultToolBarSize;
    CGSize defaultTextViewSize;
}

@property (nonatomic, readonly) CGFloat maxSpace;

@property (nonatomic, weak) id <MBDirectMessageToolbarDelegate> toolbarDelegate;

@property (nonatomic, readonly) UIBarButtonItem *cameraButton;
@property (nonatomic, readonly) UIBarButtonItem *sendButton;
@property (nonatomic, readonly) UIBarButtonItem *textViewButton;

@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, readonly) NSString *textViewText;

- (void)setMaxSpace:(CGFloat)maxSpace;
- (void)setTextViewText:(NSString *)textViewText;
- (instancetype)initWithFrame:(CGRect)frame maxSpace:(CGFloat)space;

@end



@protocol MBDirectMessageToolbarDelegate <NSObject>

- (void)toolbarDidChangeText:(MBDirectMessageToolbar *)toolbar;

@end
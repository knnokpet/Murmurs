//
//  MBTextViewTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/09/08.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBPlaceHolderTextView.h"

@interface MBTextViewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MBPlaceHolderTextView *placeholderTextView;

@end

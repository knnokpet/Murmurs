    //
//  MBSelectingListTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/08/19.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBSelectingListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

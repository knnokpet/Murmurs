//
//  MBListsTableViewCell.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/11.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBListsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *protectedImageView;


@property (nonatomic, assign) BOOL isPublic;
- (void)setIsPublic:(BOOL)isPublic;

@end

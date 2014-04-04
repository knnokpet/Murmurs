//
//  MBAOuth_TwitterAPICenter.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/03/30.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import "MBTwitterAPICenter.h"

@protocol MBAOuth_TwitterAPICenterDelegate;

@interface MBAOuth_TwitterAPICenter : MBTwitterAPICenter

@property (nonatomic, weak) id <MBAOuth_TwitterAPICenterDelegate> delegate;

@end


@protocol MBAOuth_TwitterAPICenterDelegate <NSObject>


@end
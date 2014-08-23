//
//  MBGeoPinView.h
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2014/07/21.
//  Copyright (c) 2014年 Masayuki Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionHandler)();

@interface MBGeoPinView : UIView

- (void)boundingAnimateDotWithCompletion:(CompletionHandler)completion;
- (void)contractView;
- (void)scallingAnimateDotWithCompletion:(CompletionHandler)completion;

@end

//
//  CZ2DPlayerErrorView.h
//  
//
//  Created by qcm on 17/3/9.
//  Copyright © 2017年 . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HandleClickBlock)();

@interface ZFPlayerErrorView : UIView

- (void)setHandleClickSureCallBack:(HandleClickBlock)block;
@property (assign, nonatomic) BOOL fullScreen;
@end

//
//  CZ2DContinuePlayView.h
//  
//
//  Created by qcm on 17/3/10.
//  Copyright © 2017年 . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HandleContinueBlock)();

@interface ZFContinuePlayView : UIView

@property (copy, nonatomic) NSString *videoDuration;

+ (instancetype)continuePlayView;

- (void)setHandleContinueCallBack:(HandleContinueBlock)block;

@end

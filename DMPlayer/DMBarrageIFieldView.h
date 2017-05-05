//
//  DMBarrageIFieldView.h
//  
//
//  Created by qcm on 17/3/8.
//  Copyright © 2017年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayerModel.h"
typedef NS_ENUM(NSInteger, DMBarrageType)
{
        DMBarrageTypeOptional, //竖屏
        DMBarrageTypeLandscape, //横屏
};

@interface DMBarrageIFieldView : UIView
@property (assign, nonatomic) DMBarrageType type;
@property (weak, nonatomic) UIView *showTipView;

- (void)setHandleSendBarrageCallBack:(DMSendBarrage)block;
- (void)setTextFieldBeginEditCallBack:(DMEditFilter)block;

- (BOOL)becomeFirstResponder;
- (BOOL)registerFirstResponder;

@end

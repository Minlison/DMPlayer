//
//  DMKeyboardView.h
//  
//
//  Created by qcm on 17/3/9.
//  Copyright © 2017年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMBarrageIFieldView.h"

@interface DMKeyboardView : UIView

@property (strong, nonatomic) DMBarrageIFieldView *barrageView;


+ (instancetype)keyboardView;

@property (strong, nonatomic, readonly) UIView *showTipView;
@property (assign, nonatomic) DMBarrageType type;

- (void)setHandleSendBarrageCallBack:(DMSendBarrage)block;
- (void)setTextFieldBeginEditCallBack:(DMEditFilter)block;

- (void)keyboardUpforComment;
- (void)keyboardDownForComment;

- (void)setDismissCallBack:(void(^)())block;

@end

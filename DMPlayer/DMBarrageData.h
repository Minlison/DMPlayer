//
//  DMBarrageData.h
//  DMPlayerTest
//
//  Created by MinLison on 2017/4/28.
//  Copyright © 2017年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMPlayerCommonHeader.h"
typedef NS_ENUM(NSUInteger, DMPlayerBarrageWalkDirection) {
	DMPlayerBarrageWalkDirectionR2L = 1,  // 右向左
	DMPlayerBarrageWalkDirectionL2R = 2,  // 左向右
	DMPlayerBarrageWalkDirectionT2B = 3,  // 上往下
	DMPlayerBarrageWalkDirectionB2T = 4   // 下往上
};

///注: 此处侧边的含义与悬浮弹幕(BarrageFloatSide)并不相同!
typedef NS_ENUM(NSUInteger, DMPlayerBarrageWalkSide) {
	DMPlayerBarrageWalkSideDefault = 0,   // 默认,根据选择的方向而定
	DMPlayerBarrageWalkSideRight   = 1,   // 靠右侧行驶,运动方向的右手法则
	DMPlayerBarrageWalkSideLeft    = 2    // 靠左侧行驶,运动方向的左手法则
};


@interface DMBarrageData : NSObject
@property (strong, nonatomic) UIColor *textColor;
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *stokeColor;
@property (assign, nonatomic) CGFloat stokeWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) CGFloat fontSize;
@property (assign, nonatomic) CGFloat speed;
@property (assign, nonatomic) CGFloat delay;
@property (assign, nonatomic) DMPlayerBarrageWalkDirection direction;
@property (assign, nonatomic) DMPlayerBarrageWalkSide side;
@property (assign, nonatomic) NSUInteger trackNumber;

/**
 默认弹幕样式
 
 @param text 弹幕文字
 @param playTime 弹幕发送时间
 */
+ (instancetype)defaultBarrangeWithText:(NSString *)text playTime:(NSUInteger)playTime;

/**
 发送弹幕样式
 
 @param text 弹幕文字
 直接发送, 不延迟
 */
+ (instancetype)sendBarrangeWithText:(NSString *)text;

@end

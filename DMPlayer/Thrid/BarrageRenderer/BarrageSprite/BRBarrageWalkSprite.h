// Part of BRBarrageRenderer. Created by UnAsh.
// Blog: http://blog.exbye.com
// Github: https://github.com/unash/BRBarrageRenderer

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2015年 UnAsh.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "BRBarrageSprite.h"

typedef NS_ENUM(NSUInteger, BRBarrageWalkDirection) {
    BRBarrageWalkDirectionR2L = 1,  // 右向左
    BRBarrageWalkDirectionL2R = 2,  // 左向右
    BRBarrageWalkDirectionT2B = 3,  // 上往下
    BRBarrageWalkDirectionB2T = 4   // 下往上
};

///注: 此处侧边的含义与悬浮弹幕(BRBarrageFloatSide)并不相同!
typedef NS_ENUM(NSUInteger, BRBarrageWalkSide) {
    BRBarrageWalkSideDefault = 0,   // 默认,根据选择的方向而定
    BRBarrageWalkSideRight   = 1,   // 靠右侧行驶,运动方向的右手法则
    BRBarrageWalkSideLeft    = 2    // 靠左侧行驶,运动方向的左手法则
};

/// 移动文字精灵
@interface BRBarrageWalkSprite : BRBarrageSprite
{
    CGPoint _destination;
}

/// 速度,point/second
@property(nonatomic,assign)CGFloat speed;

/// 运动方向
@property(nonatomic,assign)BRBarrageWalkDirection direction;

/// 运动侧边
@property(nonatomic,assign)BRBarrageWalkSide side;

/// 需要在originInBounds:withSprites: 方法中修改 _destination的值以表示运动的终点
@property(nonatomic,assign,readonly)CGPoint destination;

/// 轨道数量
@property(nonatomic,assign)NSUInteger trackNumber;

@end

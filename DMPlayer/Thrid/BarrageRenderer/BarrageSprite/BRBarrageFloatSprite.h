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

typedef NS_ENUM(NSUInteger, BRBarrageFloatDirection) {
    BRBarrageFloatDirectionT2B = 1,     // 上往下
    BRBarrageFloatDirectionB2T = 2      // 下往上
};

///注: 此处侧边的含义与过场弹幕(BRBarrageWalkSide)并不相同!
typedef NS_ENUM(NSUInteger, BRBarrageFloatSide) {
    BRBarrageFloatSideCenter = 0,     // 居中,默认值
    BRBarrageFloatSideRight  = 1,     // 靠右侧,屏幕右侧
    BRBarrageFloatSideLeft   = 2      // 靠左侧,屏幕左侧
};

/// 悬浮文字精灵
@interface BRBarrageFloatSprite : BRBarrageSprite

/// 存活时间
@property(nonatomic,assign)NSTimeInterval duration;

/// 方向
@property(nonatomic,assign)BRBarrageFloatDirection direction;

/// 运动侧边
@property(nonatomic,assign)BRBarrageFloatSide side;

/// 轨道数量
@property(nonatomic,assign)NSUInteger trackNumber;

/// 隐入时间, 默认0
@property(nonatomic,assign)NSTimeInterval fadeInTime;

/// 隐出时间, 默认0
@property(nonatomic,assign)NSTimeInterval fadeOutTime;

@end

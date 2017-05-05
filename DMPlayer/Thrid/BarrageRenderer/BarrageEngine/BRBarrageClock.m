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

#import "BRBarrageClock.h"
#import <QuartzCore/QuartzCore.h>
@interface BRBarrageClock()
{
        CADisplayLink * _displayLink; // 周期
        CFTimeInterval _previousDate; // 上一次更新时间
}
///是否处于启动状态
@property(nonatomic,assign)BOOL launched;
///逻辑时间
@property(nonatomic,assign)NSTimeInterval time;

@property (copy, nonatomic) void (^timeBlock)(NSTimeInterval time);

@end

@implementation BRBarrageClock

+ (instancetype)clockWithHandler:(void (^)(NSTimeInterval time))block
{
        BRBarrageClock * clock = [[BRBarrageClock alloc]initWithHandler:block];
        return clock;
}

- (instancetype)initWithHandler:(void (^)(NSTimeInterval time))block
{
        if (self = [super init]) {
                self.timeBlock = block;
        }
        return self;
}

- (void)reset
{
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        _speed = 1.0f;
        self.launched = NO;
}

- (void)update
{
        [self updateTime];
        if (self.timeBlock)
        {
                self.timeBlock(self.time);
        }
}

- (void)start
{
        if (!_displayLink)
        {
                [self reset];
        }
        
        if (!self.launched)
        {
                _previousDate = CACurrentMediaTime(); //计时器开始的时间
                [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
        self.launched = YES;
}

- (void)setSpeed:(CGFloat)speed
{
        if (speed > 0.0f)
        {
                if (_speed != speed)
                {
                        _speed = speed;
                }
        }
}

- (void)pause
{
        if (_displayLink && self.launched)
        {
                [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                self.launched = NO;
        }
}

- (void)stop
{
        [_displayLink invalidate];
        _displayLink = nil;
}

/// 更新逻辑时间系统
- (void)updateTime
{
        CFTimeInterval currentDate = CACurrentMediaTime();
        self.time += (currentDate - _previousDate) * self.speed;
        _previousDate = currentDate;
}

@end


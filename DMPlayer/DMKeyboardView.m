//
//  DMKeyboardView.m
//  
//
//  Created by qcm on 17/3/9.
//  Copyright © 2017年 . All rights reserved.
//

#import "DMKeyboardView.h"
#import <Masonry/Masonry.h>

#define SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)

#define KFIELD_HEIGHT  (50.0)

UIDeviceOrientation dm_currentOrientation()
{
	return [UIDevice currentDevice].orientation;
}

float dm_height()
{
	CGFloat height = MIN(SCREEN_WIDTH, SCREEN_HEIGHT);
	return height;
}

float dm_width()
{
	CGFloat width = MAX(SCREEN_WIDTH, SCREEN_HEIGHT);
	return width;
}

@interface DMKeyboardView ()

@property (copy, nonatomic) void(^dimissBlock)();
@property (strong, nonatomic, readwrite) UIView *showTipView;
@property (assign, nonatomic) BOOL showBarrage;
@end


@implementation DMKeyboardView

+ (instancetype)keyboardView
{
        return [[self alloc] init];
}
- (instancetype)init
{
	if (self = [super init]) {
		[self initialize];
	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
        if (self = [super initWithFrame:frame])
        {
                [self initialize];
        }
        return self;
}

- (void)initialize
{
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
	[self addSubview:self.showTipView];
	self.barrageView = [[DMBarrageIFieldView alloc] init];
	self.barrageView.showTipView = self.showTipView;
	self.barrageView.type = DMBarrageTypeLandscape;
	[self addSubview:self.barrageView];
	self.barrageView.hidden = YES;
	[self.barrageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.right.equalTo(self);
		make.top.equalTo(self).offset(dm_height() - KFIELD_HEIGHT);
		make.height.mas_equalTo(KFIELD_HEIGHT);
	}];
	[self.showTipView mas_remakeConstraints:^(MASConstraintMaker *make) {
		make.leading.trailing.top.equalTo(self);
		make.bottom.equalTo(self.barrageView);
	}];
	[self bringSubviewToFront:self.showTipView];
        //tapGesture
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardView)];
        [self addGestureRecognizer:tap];
        
        //notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)dismissKeyboardView
{
	if (self.dimissBlock)
	{
		self.dimissBlock();
	}
	[self keyboardDownForComment];
}
- (void)setType:(DMBarrageType)type
{
	_type = type;
	[self.barrageView setType:type];
}

- (void)setHandleSendBarrageCallBack:(DMSendBarrage)block
{
	self.barrageView.showTipView = self.showTipView;
	__weak __typeof(self)weakSelf = self;
	[self.barrageView setHandleSendBarrageCallBack:^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString, NSInteger playTime, DMCanSendBarrage canSend) {
		__strong __typeof(weakSelf)strongSelf = weakSelf;
		[strongSelf dismissKeyboardView];
		if (block) {
			return block(model,strongSelf.showTipView,editString,playTime,canSend);
		}
		return YES;
	}];
}
- (void)setTextFieldBeginEditCallBack:(DMEditFilter)block
{
	self.barrageView.showTipView = self.showTipView;
	__weak __typeof(self)weakSelf = self;
	[self.barrageView setTextFieldBeginEditCallBack:^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString) {
		__strong __typeof(weakSelf)strongSelf = weakSelf;
		if (block) {
			BOOL res = block(model,showTipView,editString);
			strongSelf.hidden = !res;
			return res;
		}
		return YES;
	}];
}
- (void)dealloc
{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setDismissCallBack:(void (^)())block
{
        self.dimissBlock = block;
}
#pragma mark - public Method
- (void)keyboardUpforComment
{
        [self.barrageView becomeFirstResponder];
}

- (void)keyboardDownForComment
{
        [self.barrageView registerFirstResponder];
}

#pragma mark -- 跟随键盘的坐标变化
- (void)keyBoardWillChangeFrame:(NSNotification *)notification
{
	if (self.type == DMBarrageTypeOptional) {
		return;
	}
	[UIView animateKeyframesWithDuration:0.25 delay:0 options:(UIViewKeyframeAnimationOptions)(7) animations:^{
		CGRect beginRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
		CGFloat begin_H = beginRect.size.height;
		CGFloat begin_Y = beginRect.origin.y;
		
		CGRect endRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		CGFloat end_Y = endRect.origin.y;
		
		CGFloat durationTime = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		
		
		CGFloat targetY = end_Y - KFIELD_HEIGHT;
		if( begin_H > 0 && (begin_Y - end_Y > 0 ))
		{
			// 键盘弹起
			self.showBarrage = YES;
			self.barrageView.hidden = NO;
			[self.barrageView mas_remakeConstraints:^(MASConstraintMaker *make) {
				make.leading.trailing.equalTo(self);
				make.height.mas_equalTo(KFIELD_HEIGHT);
				make.top.equalTo(self).offset(targetY);
			}];
		}
		else if (end_Y == dm_height() && begin_Y != end_Y && durationTime > 0)
		{
			//键盘收起
			[self.barrageView mas_remakeConstraints:^(MASConstraintMaker *make) {
				make.leading.trailing.equalTo(self);
				make.height.mas_equalTo(KFIELD_HEIGHT);
				make.top.equalTo(self).offset(targetY + KFIELD_HEIGHT);
			}];
			if (self.dimissBlock)
			{
				self.dimissBlock();
			}
			self.showBarrage = NO;
			[self keyboardDownForComment];
		}
		else if ((begin_Y - end_Y < 0) && durationTime == 0)
		{
			//键盘切换
			[self.barrageView mas_remakeConstraints:^(MASConstraintMaker *make) {
				make.leading.trailing.equalTo(self);
				make.height.mas_equalTo(KFIELD_HEIGHT);
				make.top.equalTo(self).offset(targetY + KFIELD_HEIGHT);
			}];
		}
		[self layoutIfNeeded];
	} completion:^(BOOL finished) {
		if (!self.showBarrage) {
			self.barrageView.hidden = YES;
		}
	}];
}
- (UIView *)showTipView
{
	if (_showTipView == nil) {
		_showTipView = [[UIView alloc] init];
		_showTipView.userInteractionEnabled = NO;
		_showTipView.backgroundColor = [UIColor clearColor];
	}
	return _showTipView;
}
@end

//
//  CZ2DContinuePlayView.m
//  
//
//  Created by qcm on 17/3/10.
//  Copyright © 2017年 . All rights reserved.
//

#import "ZFContinuePlayView.h"
#import <Masonry/Masonry.h>
#import "DMPlayer.h"
@interface ZFContinuePlayView ()
@property (strong, nonatomic) UILabel *tipLabel;
/** 继续播放 */
@property (strong, nonatomic) UIButton *continueBtn;
//视频时长
@property (strong, nonatomic) UILabel *videoTimeLabel;

@property (copy, nonatomic) HandleContinueBlock continueBlock;

@end

@implementation ZFContinuePlayView

+ (instancetype)continuePlayView
{
        return [[self alloc] init];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self _InitUI];
	}
	return self;
}
- (void)_InitUI
{
	self.backgroundColor = [UIColor blackColor];
	[self addSubview:self.tipLabel];
	[self addSubview:self.videoTimeLabel];
	[self addSubview:self.continueBtn];
	
	[self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(self.videoTimeLabel.mas_top).offset(-18);
		make.centerX.equalTo(self.videoTimeLabel);
	}];
	[self.videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.center.equalTo(self);
	}];
	[self.continueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.videoTimeLabel.mas_bottom).offset(19);
		make.centerX.equalTo(self.videoTimeLabel);
		make.height.mas_equalTo(35);
		make.width.mas_equalTo(95);
	}];
	
	self.continueBtn.layer.borderColor      = [UIColor whiteColor].CGColor;
	self.continueBtn.layer.borderWidth      = 1.5;
	self.continueBtn.layer.masksToBounds    = YES;
	self.continueBtn.layer.cornerRadius     = 3.0;
	[self.continueBtn addTarget:self action:@selector(continueBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)continueBtnClick
{
	if (self.continueBlock)
	{
		self.continueBlock();
	}
}
- (void)setHandleContinueCallBack:(HandleContinueBlock)block
{
        self.continueBlock = block;
}

- (void)setVideoDuration:(NSString *)videoDuration
{
        self.videoTimeLabel.text = [NSString stringWithFormat:@"视频时长:%@", videoDuration];
}

- (UILabel *)tipLabel
{
	if (_tipLabel == nil) {
		_tipLabel = [[UILabel alloc] init];
		_tipLabel.text = @"正在使用非WiFi网络，播放将产生流量费用";
		_tipLabel.font = [UIFont systemFontOfSize:16];
		_tipLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
	}
	return _tipLabel;
}
- (UILabel *)videoTimeLabel
{
	if (_videoTimeLabel == nil) {
		_videoTimeLabel = [[UILabel alloc] init];
		_videoTimeLabel.font = [UIFont systemFontOfSize:15];
		_videoTimeLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
	}
	return _videoTimeLabel;
}
- (UIButton *)continueBtn
{
	if (_continueBtn == nil) {
		_continueBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
		_continueBtn.titleLabel.font = [UIFont systemFontOfSize:16];
		[_continueBtn setTitle:@"继续播放" forState:(UIControlStateNormal)];
		[_continueBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
	}
	return _continueBtn;
}
@end

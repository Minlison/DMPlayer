//
//  CZ2DPlayerErrorView.m
//  
//
//  Created by qcm on 17/3/9.
//  Copyright © 2017年 . All rights reserved.
//

#import "ZFPlayerErrorView.h"
#import <Masonry/Masonry.h>
#import "DMPlayer.h"
@interface ZFPlayerErrorView ()

@property (strong, nonatomic) UIImageView *showImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) UIButton *sureButton;


@property (copy, nonatomic) HandleClickBlock handleBlock;

@end

@implementation ZFPlayerErrorView

- (instancetype)initWithFrame:(CGRect)frame
{
        if (self = [super initWithFrame:frame])
        {
                [self initializeUI];
        }
        return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
        if (self = [super initWithCoder:aDecoder])
        {
                [self initializeUI];
        }
        return self;
}
- (void)setFullScreen:(BOOL)fullScreen
{
	_fullScreen = fullScreen;
	if (fullScreen) {
		self.subTitleLabel.text = @"请点击确认退出播放器！";
	} else {
		self.subTitleLabel.text = @"点击重试!";
	}
}
- (void)initializeUI
{
        self.backgroundColor = [UIColor blackColor];
        
        UIView *view = [[UIView alloc] init];
        view.userInteractionEnabled = YES;
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
        }];
        
        self.showImageView = ({
                UIImageView *imageView = [[UIImageView alloc] initWithImage:ZFPlayerImage(@"player_pattern_error")];
                [self addSubview:imageView];
                imageView;
        });
        [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(view);
                make.top.equalTo(view);
        }];
        
        
        self.titleLabel = ({
                UILabel *label = [[UILabel alloc] init];
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = DMUIColorFromRGB(0x979797);
                label.text = @"抱歉！出错了!";
                label.font = [UIFont systemFontOfSize:15];
                [self addSubview:label];
                label;
        });
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.showImageView);
                make.top.equalTo(self.showImageView.mas_bottom).offset(10);
        }];
        
        self.subTitleLabel = ({
                UILabel *label = [[UILabel alloc] init];
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = DMUIColorFromRGB(0x535353);
                label.text = @"请点击确认退出播放器！";
                label.font = [UIFont systemFontOfSize:11];
                [self addSubview:label];
                label;
        });
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.titleLabel);
                make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        }];
        
        self.sureButton = ({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundColor:DMUIColorFromRGB(0x131313)];
                [button setTitle:@"确认" forState:UIControlStateNormal];
                [button setTitleColor:DMUIColorFromRGB(0x979797) forState:UIControlStateNormal];
                [button addTarget:self action:@selector(handlerClickBtn:) forControlEvents:UIControlEventTouchUpInside];
                button.titleLabel.font = [UIFont systemFontOfSize:15];
                [self addSubview:button];
                button;
        });
        [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.subTitleLabel);
                make.top.equalTo(self.subTitleLabel).offset(20);
                make.size.mas_equalTo(CGSizeMake(70, 30));
                make.bottom.equalTo(view.mas_bottom);
        }];
}

- (void)setHandleClickSureCallBack:(HandleClickBlock)block
{
        self.handleBlock = block;
}

- (void)handlerClickBtn:(UIButton *)sender
{
        if (self.handleBlock)
        {
                self.handleBlock();
        }
}

@end

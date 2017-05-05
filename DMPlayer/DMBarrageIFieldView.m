//
//  DMBarrageIFieldView.m
//  
//
//  Created by qcm on 17/3/8.
//  Copyright © 2017年 . All rights reserved.
//

#import "DMBarrageIFieldView.h"
#import "DMPlayerCommonHeader.h"
#import "DMPlayer.h"
#import <objc/runtime.h>
@interface UITextField (JK_InputLimit)
@property (assign, nonatomic)  NSInteger jk_maxLength;//if <=0, no limit
@end
@interface DMBarrageIFieldView ()<UITextFieldDelegate>

@property (strong, nonatomic) UIButton *sendBtn;

@property (strong, nonatomic) UITextField *textField;
//发送弹幕回调
@property (copy, nonatomic) DMSendBarrage DMSendBarrageBlock;
//点击文本框的回调
@property (copy, nonatomic) DMEditFilter DMEditFilterBlock;

@end

@implementation DMBarrageIFieldView

- (instancetype)initWithFrame:(CGRect)frame
{
        self = [super initWithFrame:frame];
        if (self)
        {
                [self initializeSet];
        }
        return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
        if (self = [super initWithCoder:aDecoder])
        {
                [self initializeSet];
        }
        return self;
}

- (void)initializeSet
{
        
        self.sendBtn = ({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.layer.cornerRadius = 2.0;
                button.layer.masksToBounds = YES;
		button.enabled = NO;
                [button addTarget:self action:@selector(clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:button];
                button;
        });
        
        self.textField = ({
                UITextField *field              = [[UITextField alloc] init];
                field.textAlignment             = NSTextAlignmentLeft;
                field.borderStyle               = UITextBorderStyleNone;
                field.font                      = [UIFont systemFontOfSize:13];
                field.jk_maxLength              = 50;
                field.leftView                  = [self placeholderView];
                field.leftViewMode              = UITextFieldViewModeAlways;
                field.rightView                 = [self placeholderView];
                field.rightViewMode             = UITextFieldViewModeAlways;
                field.delegate                  = self;
                field.tintColor                 = DMUIColorFromRGB(0x999999);
		field.delegate = self;
                [self addSubview:field];
                field;
        });
        
        //设置初始状态
        self.type = DMBarrageTypeOptional;
}

- (UIView *)placeholderView
{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 17, self.frame.size.height)];
        return view;
}

//是否竖屏
- (BOOL)isOptional
{
        return self.type == DMBarrageTypeOptional;
}

- (void)setBackgroundColor
{
        UIColor *color = [self isOptional] ? DMUIColorFromRGB(0x373737) : [UIColor whiteColor];
        self.backgroundColor = color;
}

- (void)setTextFiledBackgroundColor
{
        UIColor *color = [self isOptional] ? DMUIColorFromRGB(0x4f4f4f) : DMUIColorFromRGB(0xf4f4f4);
        self.textField.backgroundColor = color;
}

- (void)setPlaceHolderTextAndColor
{
        NSString *text = @"来发弹幕吧^_^";
        UIColor *color = [self isOptional] ? DMUIColorFromRGB(0x909090) : DMUIColorFromRGB(0xbcbcbc);
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName : [UIFont systemFontOfSize:13],
                                     NSForegroundColorAttributeName : color,
                                     };
        
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        self.textField.attributedPlaceholder = attributeText;
}

- (void)setButtonTitleAndImage
{
        UIColor *backColor      = [UIColor clearColor];
        UIImage *btnImage       = ZFPlayerImage(@"short_btn_Shape");
        NSString *title         = @"";
        UIColor *titleColor     = [UIColor clearColor];
        
        if (![self isOptional])
        {
                backColor      = DMUIColorFromRGB(0xff7d31);
                btnImage       = nil;
                title          = @"发送";
                titleColor     = [UIColor whiteColor];
        }
        
        [self.sendBtn setImage:btnImage forState:UIControlStateNormal];
        [self.sendBtn setTitle:title forState:UIControlStateNormal];
        [self.sendBtn setBackgroundColor:backColor];
        [self.sendBtn setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)setTextFieldCorner
{
        CGFloat corner = [self isOptional] ? 5.0 : 0.0;
        self.textField.layer.cornerRadius = corner;
        self.textField.layer.masksToBounds = YES;
}

- (void)setTextFiledTextColor
{
        UIColor *color = [self isOptional] ? DMUIColorFromRGB(0xBCBCBC) : [UIColor blackColor];
        self.textField.textColor = color;
}

- (void)updateUI
{
        [self setPlaceHolderTextAndColor];
        [self setButtonTitleAndImage];
        [self setBackgroundColor];
        [self setTextFiledBackgroundColor];
        [self setTextFieldCorner];
        [self setTextFiledTextColor];
}

- (void)setHandleSendBarrageCallBack:(DMSendBarrage)block
{
        self.DMSendBarrageBlock = block;
}

- (void)setTextFieldBeginEditCallBack:(DMEditFilter)block
{
        self.DMEditFilterBlock = block;
}

- (void)setType:(DMBarrageType)type
{
        _type = type;
        [self updateUI];
        [self setNeedsLayout];
}

- (BOOL)becomeFirstResponder
{
        return [self.textField becomeFirstResponder];
}

- (BOOL)registerFirstResponder
{
        return [self.textField resignFirstResponder];
}

- (void)clickSendButton:(UIButton *)sender
{
        NSString *text = self.textField.text;
        if (DMNULLString(text))
        {
                return;
        }
        
        if (self.DMSendBarrageBlock)
        {
		self.DMSendBarrageBlock(nil,self.showTipView,text,0, ^(BOOL canSend) {
		});
		self.textField.text = nil;
        }
}

- (void)layoutSubviews
{
        [super layoutSubviews];
        
        //button
        CGFloat btn_width  = self.frame.size.height;
        CGFloat btn_height = btn_width;
        CGFloat btn_x      = self.frame.size.width - btn_width;
        CGFloat btn_y      = 0.0;
        if (![self isOptional])
        {
                btn_width       = 70.0;
                btn_height      = 33.0;
                btn_y           = (self.frame.size.height - btn_height) * 0.5;
                btn_x           = self.frame.size.width - btn_width - 8.0;
        }
        
        CGRect btnFrame         = self.sendBtn.frame;
        btnFrame.origin.x       = btn_x;
        btnFrame.origin.y       = btn_y;
        btnFrame.size.width     = btn_width;
        btnFrame.size.height    = btn_height;
        self.sendBtn.frame      = btnFrame;
        
        
        
        CGFloat x       = 13.0;
        CGFloat y       = 6.0;
        CGFloat width   = btn_x - x - 2;
        CGFloat height  = self.frame.size.height - y * 2;
        if (![self isOptional])
        {
                x       = 8.0;
                y       = 8.0;
                width   = btn_x - x * 2;
                height  = self.frame.size.height - 2 * y;
        }
        
        //textFeild
        CGRect fieldFrame       = self.textField.frame;
        fieldFrame.origin.x     = x;
        fieldFrame.origin.y     = y;
        fieldFrame.size.width   = width;
        fieldFrame.size.height  = height;
        self.textField.frame    = fieldFrame;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
        if (self.DMEditFilterBlock)
        {
                return self.DMEditFilterBlock([ZFPlayerView sharedPlayerView].playerModel,self.showTipView,self.textField.text);
        }
	return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	
	NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (string.length < 1)
	{
		self.sendBtn.enabled = (text.length > 0);
		return YES;
	}
	
	if ([string stringByReplacingOccurrencesOfString:@" " withString:@""].length < 1)
	{
		self.sendBtn.enabled = (text.length > 0);
		return NO;
	}
	self.sendBtn.enabled = (text.length > 0);
	if (self.DMEditFilterBlock) {
		return self.DMEditFilterBlock([ZFPlayerView sharedPlayerView].playerModel,self.showTipView,text);
	}
	return NO;
}
@end


static const void *JKTextFieldInputLimitMaxLength = &JKTextFieldInputLimitMaxLength;
@implementation UITextField (JK_InputLimit)

- (NSInteger)jk_maxLength {
	return [objc_getAssociatedObject(self, JKTextFieldInputLimitMaxLength) integerValue];
}
- (void)setJk_maxLength:(NSInteger)maxLength {
	objc_setAssociatedObject(self, JKTextFieldInputLimitMaxLength, @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self addTarget:self action:@selector(jk_textFieldTextDidChange) forControlEvents:UIControlEventEditingChanged];
}
- (void)jk_textFieldTextDidChange {
	NSString *toBeString = self.text;
	//获取高亮部分
	UITextRange *selectedRange = [self markedTextRange];
	UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
	
	//没有高亮选择的字，则对已输入的文字进行字数统计和限制
	//在iOS7下,position对象总是不为nil
	if ( (!position ||!selectedRange) && (self.jk_maxLength > 0 && toBeString.length > self.jk_maxLength))
	{
		NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.jk_maxLength];
		if (rangeIndex.length == 1)
		{
			self.text = [toBeString substringToIndex:self.jk_maxLength];
		}
		else
		{
			NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.jk_maxLength)];
			NSInteger tmpLength;
			if (rangeRange.length > self.jk_maxLength) {
				tmpLength = rangeRange.length - rangeIndex.length;
			}else{
				tmpLength = rangeRange.length;
			}
			self.text = [toBeString substringWithRange:NSMakeRange(0, tmpLength)];
		}
	}
}
@end

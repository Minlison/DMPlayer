//
//  DMBarrageWalkTextSprite.m
//  Pods
//
//  Created by qcm on 17/3/16.
//
//

#import "DMBarrageWalkTextSprite.h"

@implementation DMBarrageWalkTextSprite

@synthesize fontSize = _fontSize;
@synthesize textColor = _textColor;
@synthesize text = _text;
@synthesize fontFamily = _fontFamily;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize attributedText = _attributedText;
@synthesize stokeColor = _stokeColor;
@synthesize stokeWidth = _stokeWidth;

- (instancetype)init
{
	if (self = [super init]) {
		_textColor = [UIColor blackColor];
		_fontSize = 16.0f;
		_shadowColor = nil;
		_shadowOffset = CGSizeMake(0, -1);
	}
	return self;
}

#pragma mark - launch

- (UIView *)bindingView
{
	DMBarrageLabel * label  = [[DMBarrageLabel alloc] init];
	label.text              = self.text;
	label.textColor         = self.textColor;
	label.shadowColor       = self.shadowColor;
	label.shadowOffset      = self.shadowOffset;
	label.stokeColor        = self.stokeColor;
	label.strokeWidth       = self.stokeWidth;
	label.layer.borderColor = self.borderColor.CGColor;
	label.layer.borderWidth = self.borderWidth;
	label.font              = self.fontFamily ? [UIFont fontWithName:self.fontFamily size:self.fontSize]:[UIFont systemFontOfSize:self.fontSize];
	if (self.attributedText)
	{
		label.attributedText = self.attributedText;
	}
	return label;
}

@end

//
//  DMBarrageData.m
//  DMPlayerTest
//
//  Created by MinLison on 2017/4/28.
//  Copyright © 2017年 . All rights reserved.
//

#import "DMBarrageData.h"
#import "DMPlayerCommonHeader.h"
#import "DMBarrageWalkTextSprite.h"
#import "DMBarrageDataPrv.h"
@implementation DMBarrageData
- (instancetype)init
{
	if (self = [super init]) {
		self.text = @"";
		self.textColor = [UIColor whiteColor];
		self.stokeColor = [UIColor blackColor];
		self.borderColor = [UIColor clearColor];
		self.borderWidth = 0;
		self.stokeWidth = 1;
		self.fontSize = 18;
		self.speed = arc4random_uniform(100) + 50;
		self.delay = 0;
		self.direction = DMPlayerBarrageWalkDirectionR2L;
		self.side = DMPlayerBarrageWalkSideDefault;
		self.trackNumber = 5;
	}
	return self;
}
+ (instancetype)defaultBarrangeWithText:(NSString *)text playTime:(NSUInteger)playTime
{
	DMBarrageData *data = [[self alloc] init];
	data.text = text;
	data.borderWidth = 0;
	data.delay = playTime;
	return data;
}
+ (instancetype)sendBarrangeWithText:(NSString *)text
{
	DMBarrageData *data = [[self alloc] init];
	data.text = text;
	data.delay = 0.5;
	data.borderWidth = 1;
	data.borderColor = [UIColor whiteColor];
	return data;
}

@end

@implementation DMBarrageData (Prv)

- (BRBarrageDescriptor *)descriptor
{
	BRBarrageDescriptor * descriptor          = [[BRBarrageDescriptor alloc] init];
	descriptor.spriteName                   = NSStringFromClass([DMBarrageWalkTextSprite class]);
	descriptor.params[@"text"]              = DMNULLStringDefault(self.text, @"");
	descriptor.params[@"textColor"]         = DMNULLObjectDefault(self.textColor,[UIColor whiteColor]);
	descriptor.params[@"stokeColor"]        = DMNULLObjectDefault(self.stokeColor,[UIColor blackColor]);
	descriptor.params[@"borderColor"]	= DMNULLObjectDefault(self.borderColor,[UIColor whiteColor]);
	descriptor.params[@"borderWidth"]	= @(self.borderWidth);
	descriptor.params[@"stokeWidth"]        = @(self.stokeWidth);
	descriptor.params[@"fontSize"]          = @(self.fontSize);
	descriptor.params[@"speed"]             = @(self.speed);
	descriptor.params[@"delay"]             = @(self.delay);
	descriptor.params[@"direction"]         = @(self.direction);
	descriptor.params[@"side"]              = @(self.side);
	descriptor.params[@"trackNumber"]       = @(self.trackNumber);
	return descriptor;
}

@end

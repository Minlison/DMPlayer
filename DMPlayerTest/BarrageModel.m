//
//  BarrageModel.m
//  
//
//  Created by qcm on 17/3/9.
//  Copyright © 2017年 . All rights reserved.
//

#import "BarrageModel.h"

@implementation BarrageModel
- (DMBarrageData *)barrageData
{
	return [DMBarrageData defaultBarrangeWithText:self.bullet_screen playTime:self.play_time.integerValue];
}
@end

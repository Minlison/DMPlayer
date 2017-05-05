//
//  BarrageModel.h
//  
//
//  Created by qcm on 17/3/9.
//  Copyright © 2017年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"
#import <DMPlayer/DMPlayer.h>
@interface BarrageModel : NSObject <YYModel>

@property (strong, nonatomic)   NSNumber *play_time;    //要显示弹幕的视频时间点（单位：秒）
@property (copy, nonatomic)     NSString *bullet_screen;// 弹幕
- (DMBarrageData *)barrageData;
@end

//
//  DMBarrageDataPrv.h
//  DMPlayerTest
//
//  Created by MinLison on 2017/4/28.
//  Copyright © 2017年 . All rights reserved.
//

#import "DMBarrageData.h"
#import "BRBarrageHeader.h"
@interface DMBarrageData (Prv)
@property (strong, nonatomic, readonly) BRBarrageDescriptor *descriptor;
@end

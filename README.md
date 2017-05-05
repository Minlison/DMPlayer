# DMPlayer
###播放器: [ZFPlayer](https://github.com/renzifeng/ZFPlayer), 播放器的使用方法可详细参考[ZFPlayer](https://github.com/renzifeng/ZFPlayer)使用.

###弹幕: [BarrageRenderer](https://github.com/unash/BarrageRenderer)

###以上都进行过二次修改.
####增加了以下内容:
***
* 增加弹幕发送的视图,可以使用

```
ZFPlayerView 的属性 showKeyboardView 来空值是否显示发送弹幕的视图.
ZFPlayerModel 增加了属性 
* currentTime, 表示当前播放时间. 
* userInfo, 附加参数, 直接回传, 不改变
* loadBarranges, 弹幕加
* editFilter, 编辑弹幕
* sendBarrangeText, 发送弹幕
* 使用方法
		playerModel.loadBarranges = ^(ZFPlayerModel *model, DMBarrage completion) {
		    
		    NSString *barrageString = @"[{\"bullet_screen\":\"咯哦去\",\"play_time\":4},{\"bullet_screen\":\"会哦咯胃口明\",\"play_time\":19}]";
		    NSArray <BarrageModel *>*barrageModels = [NSArray yy_modelArrayWithClass:[BarrageModel class] json:barrageString];
		    NSMutableArray <DMBarrageData *>*tmp = [NSMutableArray arrayWithCapacity:barrageModels.count];
		    [barrageModels enumerateObjectsUsingBlock:^(BarrageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			    [tmp addObject:[DMBarrageData defaultBarrangeWithText:obj.bullet_screen playTime:obj.play_time.integerValue]];
		    }];
		    completion(tmp);
	    };
	    
	    playerModel.editFilter = ^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString) {
	    /// 用来做自己的判断.
		    return YES;
	    };
	    
	    playerModel.sendBarrangeText = ^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString, NSInteger playTime, DMCanSendBarrage canSend) {
	    /// 用来做自己判断
	    /// 异步
			dispatch_async(dispatch_get_global_queue(0, 0), ^{
			    canSend(YES)
		    })
	    	return NO;
	    ///   同步
		///	return YES;
	    };
```

* 更改全屏方法, 使用 present 控制器的方法来控制全屏


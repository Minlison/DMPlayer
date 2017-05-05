//
//  ZFTableViewController.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFTableViewController.h"
#import "ZFPlayerCell.h"
#import "ZFVideoModel.h"
#import "ZFVideoResolution.h"
#import <Masonry/Masonry.h>
#import "ZFDownloadManager.h"
#import "DMPlayer.h"
#import "BarrageModel.h"
#import "YYModel.h"

@interface ZFTableViewController () <ZFPlayerDelegate>

@property (nonatomic, strong) NSMutableArray      *dataSource;
@property (nonatomic, strong) ZFPlayerView        *playerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@end

@implementation ZFTableViewController

#pragma mark - life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 379.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self requestData];
}

// 页面消失时候
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	if (!ZFPlayerShared.isLandscape) {
		[self.playerView resetPlayer];
	}
}

- (void)requestData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    self.dataSource = @[].mutableCopy;
    NSArray *videoList = [rootDict objectForKey:@"videoList"];
    for (NSDictionary *dataDic in videoList) {
        ZFVideoModel *model = [[ZFVideoModel alloc] init];
        [model setValuesForKeysWithDictionary:dataDic];
        [self.dataSource addObject:model];
    }
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	if (ZFPlayerShared.isLandscape) {
		return UIInterfaceOrientationLandscapeRight;
	}
	return UIInterfaceOrientationPortrait;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (ZFPlayerShared.isLandscape) {
		return UIInterfaceOrientationMaskLandscape;
	}
	return UIInterfaceOrientationMaskPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    // 这里设置横竖屏不同颜色的statusbar
    if (ZFPlayerShared.isLandscape) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return ZFPlayerShared.isStatusBarHidden;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier        = @"playerCell";
    ZFPlayerCell *cell                 = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    // 取到对应cell的model
    __block ZFVideoModel *model        = self.dataSource[indexPath.row];
    // 赋值model
    cell.model                         = model;
    __block NSIndexPath *weakIndexPath = indexPath;
    __block ZFPlayerCell *weakCell     = cell;
    __weak typeof(self)  weakSelf      = self;
    // 点击播放的回调
    cell.playBlock = ^(UIButton *btn){
        
        // 分辨率字典（key:分辨率名称，value：分辨率url)
        NSMutableDictionary *dic = @{}.mutableCopy;
        for (ZFVideoResolution * resolution in model.playInfo) {
            [dic setValue:resolution.url forKey:resolution.name];
        }
        // 取出字典中的第一视频URL
        NSURL *videoURL = [NSURL URLWithString:dic.allValues.firstObject];
        
        ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
        playerModel.title            = model.title;
        playerModel.videoURL         = videoURL;
        playerModel.placeholderImageURLString = model.coverForFeed;
        playerModel.scrollView       = weakSelf.tableView;
        playerModel.indexPath        = weakIndexPath;
	    playerModel.editFilter = ^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString) {
		    return YES;
	    };
	    playerModel.sendBarrangeText = ^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString, NSInteger playTime, DMCanSendBarrage canSend) {
		    return YES;
	    };
	    
	    playerModel.fatherView = weakCell.picView;
        // 赋值分辨率字典
//        playerModel.resolutionDic    = dic;
        // player的父视图tag
        playerModel.fatherViewTag    = weakCell.picView.tag;
	    playerModel.loadBarranges = ^(ZFPlayerModel *model, DMBarrage completion) {
		    
		    NSString *barrageString = @"[{\"bullet_screen\":\"咯哦去\",\"play_time\":4},{\"bullet_screen\":\"会哦咯胃口明\",\"play_time\":19},{\"bullet_screen\":\"还8了来咯咯我\",\"play_time\":14},{\"bullet_screen\":\"hhhhghjj\",\"play_time\":1},{\"bullet_screen\":\"hhhh\",\"play_time\":26},{\"bullet_screen\":\"家里多咯看看\",\"play_time\":74},{\"bullet_screen\":\"溃破你有空截图\",\"play_time\":79},{\"bullet_screen\":\"老婆口红我叫老公哦\",\"play_time\":91},{\"bullet_screen\":\"不请进来五六\",\"play_time\":97},{\"bullet_screen\":\"了居然体好可怕龙看看\",\"play_time\":102},{\"bullet_screen\":\"胡咯咯也可以可以\",\"play_time\":10},{\"bullet_screen\":\"敏敏婆婆公公\",\"play_time\":2},{\"bullet_screen\":\"你既然过几钟后宫婆婆公婆公公\",\"play_time\":9},{\"bullet_screen\":\"弹幕来了\",\"play_time\":2},{\"bullet_screen\":\"好无聊\",\"play_time\":7},{\"bullet_screen\":\"你真是！！太吵！！！！！了！！！！！\",\"play_time\":16},{\"bullet_screen\":\"简直\",\"play_time\":29},{\"bullet_screen\":\"会哦也可以就行了\",\"play_time\":9},{\"bullet_screen\":\"一抹人就给我\",\"play_time\":274},{\"bullet_screen\":\"你您破手机\",\"play_time\":279},{\"bullet_screen\":\"弹幕护体！！！\",\"play_time\":13},{\"bullet_screen\":\"明敏明\",\"play_time\":282},{\"bullet_screen\":\"经老婆婆婆婆公公公\",\"play_time\":286},{\"bullet_screen\":\"灵敏明明明明哦\",\"play_time\":294},{\"bullet_screen\":\"！！！！\",\"play_time\":16},{\"bullet_screen\":\"简直\",\"play_time\":29},{\"bullet_screen\":\"会哦也可以就行了\",\"play_time\":9},{\"bullet_screen\":\"一抹人就给我\",\"play_time\":274},{\"bullet_screen\":\"你您破手机\",\"play_time\":279},{\"bullet_screen\":\"弹幕护体！！！\",\"play_time\":13},{\"bullet_screen\":\"明敏明\",\"play_time\":282},{\"bullet_screen\":\"经老婆婆婆婆公公公\",\"play_time\":286},{\"bullet_screen\":\"灵敏明明明明哦\",\"play_time\":294},{\"bullet_screen\":\"\\\\346来临时空来看看\",\"play_time\":299},{\"bullet_screen\":\"你弟女孩领地明敏\",\"play_time\":303},{\"bullet_screen\":\"前方高能！！！\",\"play_time\":4},{\"bullet_screen\":\"前方高能！！！\",\"play_time\":29},{\"bullet_screen\":\"前方高能！！！\",\"play_time\":4},{\"bullet_screen\":\"前方高能！！！\",\"play_time\":7},{\"bullet_screen\":\"前方高能！！！\",\"play_time\":4},{\"bullet_screen\":\"前方高能！！！\",\"play_time\":4},{\"bullet_screen\":\"前方高能！！！\",\"play_time\":7},{\"bullet_screen\":\"简直了！！！\",\"play_time\":4},{\"bullet_screen\":\"up主\",\"play_time\":7},{\"bullet_screen\":\"丧心病狂！！！\",\"play_time\":14},{\"bullet_screen\":\"hbhjjjjj咯哦哦\",\"play_time\":3},{\"bullet_screen\":\"聊聊天空调监控\",\"play_time\":71},{\"bullet_screen\":\"66666666\",\"play_time\":18},{\"bullet_screen\":\"啦啦啦\",\"play_time\":9},{\"bullet_screen\":\"能加颜色吗？我可以来会员么\",\"play_time\":16},{\"bullet_screen\":\"盗墓\",\"play_time\":108},{\"bullet_screen\":\"aaaaaaa\",\"play_time\":5},{\"bullet_screen\":\"厉害\",\"play_time\":5},{\"bullet_screen\":\"看看\",\"play_time\":2},{\"bullet_screen\":\"吃屎去吧\",\"play_time\":8},{\"bullet_screen\":\"好黑啊\",\"play_time\":8},{\"bullet_screen\":\"我靠\",\"play_time\":86},{\"bullet_screen\":\"ghhbnn\",\"play_time\":605},{\"bullet_screen\":\"ggg\",\"play_time\":4},{\"bullet_screen\":\"ujii\",\"play_time\":3},{\"bullet_screen\":\"yhhh\",\"play_time\":9},{\"bullet_screen\":\"uuui\",\"play_time\":2},{\"bullet_screen\":\"fvbbj\",\"play_time\":7},{\"bullet_screen\":\"sdff陶钰玉\",\"play_time\":12},{\"bullet_screen\":\"走你\",\"play_time\":1},{\"bullet_screen\":\"走你\",\"play_time\":5},{\"bullet_screen\":\"再来\",\"play_time\":5},{\"bullet_screen\":\"嘿嘿\",\"play_time\":13},{\"bullet_screen\":\"哈哈哈哈\",\"play_time\":13},{\"bullet_screen\":\"哦哦哦\",\"play_time\":13},{\"bullet_screen\":\"看看\",\"play_time\":5},{\"bullet_screen\":\"摸摸你\",\"play_time\":11},{\"bullet_screen\":\"我的\",\"play_time\":3},{\"bullet_screen\":\"啦啦啦\",\"play_time\":7}]";
		    NSArray <BarrageModel *>*barrageModels = [NSArray yy_modelArrayWithClass:[BarrageModel class] json:barrageString];
		    NSMutableArray <DMBarrageData *>*tmp = [NSMutableArray arrayWithCapacity:barrageModels.count];
		    [barrageModels enumerateObjectsUsingBlock:^(BarrageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			    [tmp addObject:[DMBarrageData defaultBarrangeWithText:obj.bullet_screen playTime:obj.play_time.integerValue]];
		    }];
		    completion(tmp);
	    };
        
        // 设置播放控制层和model
        [weakSelf.playerView playerControlView:nil playerModel:playerModel];
        // 下载功能
        weakSelf.playerView.hasDownload = NO;
        // 自动播放
        [weakSelf.playerView autoPlayTheVideo];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
}

- (ZFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [ZFPlayerView sharedPlayerView];
        _playerView.delegate = self;
        // 当cell播放视频由全屏变为小屏时候，不回到中间位置
        _playerView.cellPlayerOnCenter = NO;
	    _playerView.hasPreviewView = YES;
	    _playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspectFill;
        
        // 当cell划出屏幕的时候停止播放
        // _playerView.stopPlayWhileCellNotVisable = YES;
        //（可选设置）可以设置视频的填充模式，默认为（等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
        // 静音
        // _playerView.mute = YES;
    }
    return _playerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ZFPlayerControlView alloc] init];
    }
    return _controlView;
}

#pragma mark - ZFPlayerDelegate

- (void)zf_playerDownload:(NSString *)url {
    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
    NSString *name = [url lastPathComponent];
    [[ZFDownloadManager sharedDownloadManager] downFileUrl:url filename:name fileimage:nil];
    // 设置最多同时下载个数（默认是3）
    [ZFDownloadManager sharedDownloadManager].maxCount = 4;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

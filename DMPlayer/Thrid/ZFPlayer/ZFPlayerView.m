//
//  ZFPlayerView.m
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

#import "ZFPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+CustomControlView.h"
#import "DMPlayer.h"
#import "DMKeyboardView.h"
#import "ZFFullScreenViewController.h"
#import "DMBarrageDataPrv.h"
#import "DMPlayerCommonHeader.h"
#import <Masonry/Masonry.h>
#import "DMPlayer.h"
#import "ZFPlayerControlView.h"
#define CellPlayerFatherViewTag  200

//忽略编译器的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
	PanDirectionHorizontalMoved, // 横向移动
	PanDirectionVerticalMoved    // 纵向移动
};

@interface ZFPlayerView () <UIGestureRecognizerDelegate,UIAlertViewDelegate>

/** 播放属性 */
@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@property (nonatomic, strong) AVURLAsset             *urlAsset;
@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer          *playerLayer;
@property (nonatomic, strong) id                     timeObserve;
/** 滑杆 */
@property (nonatomic, strong) UISlider               *volumeViewSlider;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat                sumTime;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection           panDirection;
/** 播发器的几种状态 */
@property (nonatomic, assign, readwrite) ZFPlayerState          state;
/** 当前播放时间 */
@property (assign, nonatomic) NSInteger currentTime;
/** 是否为全屏 */
@property (nonatomic, assign, readwrite) BOOL                   isFullScreen;
/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL                   isLocked;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL                   isPauseByUser;
/** 是否播放本地文件 */
@property (nonatomic, assign) BOOL                   isLocalVideo;
/** slider上次的值 */
@property (nonatomic, assign) CGFloat                sliderLastValue;
/** 是否再次设置URL播放视频 */
@property (nonatomic, assign) BOOL                   repeatToPlay;
/** 播放完了*/
@property (nonatomic, assign) BOOL                   playDidEnd;
/** 进入后台*/
@property (nonatomic, assign) BOOL                   didEnterBackground;
/** 是否自动播放 */
@property (nonatomic, assign) BOOL                   isAutoPlay;
/** 单击 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
/** 双击 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
/** 视频URL的数组 */
@property (nonatomic, strong) NSArray                *videoURLArray;
/** slider预览图 */
@property (nonatomic, strong) UIImage                *thumbImg;
/** 亮度view */
@property (nonatomic, strong) ZFBrightnessView       *brightnessView;
/** 视频填充模式 */
@property (nonatomic, copy) NSString                 *videoGravity;

#pragma mark - UITableViewCell PlayerView

/** palyer加到tableView */
@property (nonatomic, strong) UIScrollView           *scrollView;
@property (strong, nonatomic) UIScrollView *judgeScrollView;
/** player所在cell的indexPath */
@property (nonatomic, strong) NSIndexPath            *indexPath;
/** ViewController中页面是否消失 */
@property (nonatomic, assign) BOOL                   viewDisappear;
/** 是否在cell上播放video */
@property (nonatomic, assign) BOOL                   isCellVideo;
/** 是否缩小视频在底部 */
@property (nonatomic, assign) BOOL                   isBottomVideo;
/** 是否切换分辨率*/
@property (nonatomic, assign) BOOL                   isChangeResolution;
/** 是否正在拖拽 */
@property (nonatomic, assign) BOOL                   isDragged;
/** 小窗口距屏幕右边和下边的距离 */
@property (nonatomic, assign) CGPoint                shrinkRightBottomPoint;

@property (nonatomic, strong) UIPanGestureRecognizer *shrinkPanGesture;
@property (strong, nonatomic) UIPinchGestureRecognizer *shrinkPinchGesture;

@property (nonatomic, strong) UIView                 *controlView;
@property (nonatomic, strong, readwrite) ZFPlayerModel          *playerModel;
@property (nonatomic, assign) NSInteger              seekTime;
@property (nonatomic, strong) NSURL                  *videoURL;
@property (nonatomic, strong) NSDictionary           *resolutionDic;
@property (strong, nonatomic) DMKeyboardView *keyBoardView;
@property (strong, nonatomic) DMBarrageIFieldView *fieldView;
@property (strong, nonatomic) ZFFullScreenViewController *fullScreenViewController;

@end

@implementation ZFPlayerView

#pragma mark - life Cycle

/**
 *  代码初始化调用此方法
 */
- (instancetype)init {
	self = [super init];
	if (self) { [self initializeThePlayer]; }
	return self;
}
- (void)didMoveToWindow
{
	NSLog(@"didMoveToWindow");
}
/**
 *  storyboard、xib加载playerView会调用此方法
 */
- (void)awakeFromNib {
	[super awakeFromNib];
	[self initializeThePlayer];
}

/**
 *  初始化player
 */
- (void)initializeThePlayer {
	self.cellPlayerOnCenter = YES;
}

- (void)dealloc {
	NSLog(@"playerView Dealloc ");
	self.playerItem = nil;
	self.scrollView  = nil;
	ZFPlayerShared.isLockScreen = NO;
	[self.controlView zf_playerCancelAutoFadeOutControlView];
	// 移除通知
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	// 移除time观察者
	if (self.timeObserve) {
		[self.player removeTimeObserver:self.timeObserve];
		self.timeObserve = nil;
	}
}

/**
 *  在当前页面，设置新的Player的URL调用此方法
 */
- (void)resetToPlayNewURL {
	self.repeatToPlay = YES;
	[self resetPlayer];
}

#pragma mark - 观察者、通知

/**
 *  添加观察者、通知
 */
- (void)addNotifications {
	// app退到后台
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
	// app进入前台
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
	
	// 监听耳机插入和拔掉通知
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
	
	// 监测设备方向
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self
						 selector:@selector(onDeviceOrientationChange)
						     name:UIDeviceOrientationDidChangeNotification
						   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
						 selector:@selector(onStatusBarOrientationChange)
						     name:UIApplicationDidChangeStatusBarOrientationNotification
						   object:nil];
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
	[super layoutSubviews];
	self.playerLayer.frame = self.bounds;
}

#pragma mark - Public Method

/**
 *  单例，用于列表cell上多个视频
 *
 *  @return ZFPlayer
 */
+ (instancetype)sharedPlayerView {
	static ZFPlayerView *playerView = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		playerView = [[ZFPlayerView alloc] init];
	});
	return playerView;
}

- (void)playerControlView:(UIView *)controlView playerModel:(ZFPlayerModel *)playerModel {
	if (!controlView) {
		// 指定默认控制层
		ZFPlayerControlView *defaultControlView = [[ZFPlayerControlView alloc] init];
		self.controlView = defaultControlView;
	} else {
		self.controlView = controlView;
	}
	self.playerModel = playerModel;
}

/**
 * 使用自带的控制层时候可使用此API
 */
- (void)playerModel:(ZFPlayerModel *)playerModel {
	[self playerControlView:nil playerModel:playerModel];
}

/**
 *  自动播放，默认不自动播放
 */
- (void)autoPlayTheVideo {
	// 设置Player相关参数
	[self configZFPlayer];
}

/**
 *  player添加到fatherView上
 */
- (void)addPlayerToFatherView:(UIView *)view {
	// 这里应该添加判断，因为view有可能为空，当view为空时[view addSubview:self]会crash
	if (view) {
		[self removeFromSuperview];
		[view addSubview:self];
		[self mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.mas_offset(UIEdgeInsetsZero);
		}];
		
		if (self.isFullScreen) {
			[self.keyBoardView removeFromSuperview];
			[view addSubview:self.keyBoardView];
			self.keyBoardView.hidden = YES;
			[self.keyBoardView mas_remakeConstraints:^(MASConstraintMaker *make) {
				make.edges.mas_offset(UIEdgeInsetsZero);
			}];
		}
		self.showKeyboardView = self.showKeyboardView;
		
	}
}

/**
 *  重置player
 */
- (void)resetPlayer {
	// 改为为播放完
	self.state = ZFPlayerStateUnKnown;
	self.playDidEnd         = NO;
	self.playerItem         = nil;
	self.didEnterBackground = NO;
	// 视频跳转秒数置0
	self.seekTime           = 0;
	self.isAutoPlay         = NO;
	if (self.timeObserve) {
		[self.player removeTimeObserver:self.timeObserve];
		self.timeObserve = nil;
	}
	// 移除通知
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	// 暂停
	[self pause];
	// 移除原来的layer
	[self.playerLayer removeFromSuperlayer];
	// 替换PlayerItem为nil
	[self.player replaceCurrentItemWithPlayerItem:nil];
	// 把player置为nil
	self.imageGenerator = nil;
	if (self.isChangeResolution) { // 切换分辨率
		[self.controlView zf_playerResetControlViewForResolution];
		self.isChangeResolution = NO;
	}else { // 重置控制层View
		[self.controlView zf_playerResetControlView];
	}
	self.controlView   = nil;
	// 非重播时，移除当前playerView
	if (!self.repeatToPlay) { [self removeFromSuperview]; }
	// 底部播放video改为NO
	self.isBottomVideo = NO;
	// cell上播放视频 && 不是重播时
	if (self.isCellVideo && !self.repeatToPlay) {
		// vicontroller中页面消失
		self.viewDisappear = YES;
		self.isCellVideo   = NO;
		self.scrollView     = nil;
		self.indexPath     = nil;
	}
}

/**
 *  在当前页面，设置新的视频时候调用此方法
 */
- (void)resetToPlayNewVideo:(ZFPlayerModel *)playerModel {
	self.repeatToPlay = YES;
	[self resetPlayer];
	self.playerModel = playerModel;
	[self configZFPlayer];
}

/**
 *  播放
 */
- (void)play {
	[self playByUser:YES];
}
- (void)playByUser:(BOOL)user
{
	[self.controlView zf_playerPlayBtnState:YES];
	if (self.state == ZFPlayerStatePause) { self.state = ZFPlayerStatePlaying; }
	self.isPauseByUser = NO;
	[_player play];
}
/**
 * 暂停
 */
- (void)pause {
	[self pauseByUser:YES];
}
- (void)pauseByUser:(BOOL)user {
	[self.controlView zf_playerPlayBtnState:NO];
	if (self.state == ZFPlayerStatePlaying) { self.state = ZFPlayerStatePause;}
	self.isPauseByUser = user;
	[_player pause];
}

#pragma mark - Private Method

/**
 *  用于cell上播放player
 *
 *  @param scrollView tableView
 *  @param indexPath indexPath
 */
- (void)cellVideoWithScrollView:(UIScrollView *)scrollView
		    AtIndexPath:(NSIndexPath *)indexPath {
	// 如果页面没有消失，并且playerItem有值，需要重置player(其实就是点击播放其他视频时候)
	if (!self.viewDisappear && self.playerItem) { [self resetPlayer]; }
	// 在cell上播放视频
	self.isCellVideo      = YES;
	// viewDisappear改为NO
	self.viewDisappear    = NO;
	// 设置tableview
	self.scrollView       = scrollView;
	// 设置indexPath
	self.indexPath        = indexPath;
	// 在cell播放
	[self.controlView zf_playerCellPlay];
	
	self.shrinkPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shrikPanAction:)];
	self.shrinkPanGesture.delegate = self;
	[self addGestureRecognizer:self.shrinkPanGesture];
	
	self.shrinkPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkPinchAction:)];
	self.shrinkPinchGesture.delegate = self;
	[self addGestureRecognizer:self.shrinkPinchGesture];
}

/**
 *  设置Player相关参数
 */
- (void)configZFPlayer {
	self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
	// 初始化playerItem
	self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
	// 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
	if (!self.player) {
		self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
		// 初始化playerLayer
		self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	} else {
		[self.player replaceCurrentItemWithPlayerItem:self.playerItem];
	}
	
	self.backgroundColor = [UIColor blackColor];
	// 此处为默认视频填充模式
	self.playerLayer.videoGravity = self.videoGravity;
	
	// 自动播放
	self.isAutoPlay = YES;
	
	// 添加播放进度计时器
	[self createTimer];
	
	// 获取系统音量
	[self configureVolume];
	
	// 本地文件不设置ZFPlayerStateBuffering状态
	if ([self.videoURL.scheme isEqualToString:@"file"]) {
		self.state = ZFPlayerStatePlaying;
		self.isLocalVideo = YES;
		[self.controlView zf_playerDownloadBtnState:NO];
	} else {
		self.state = ZFPlayerStateBuffering;
		self.isLocalVideo = NO;
		[self.controlView zf_playerDownloadBtnState:YES];
	}
	// 开始播放
	[self play];
	self.isPauseByUser = NO;
}

/**
 *  创建手势
 */
- (void)createGesture {
	// 单击
	self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
	self.singleTap.delegate                = self;
	self.singleTap.numberOfTouchesRequired = 1; //手指数
	self.singleTap.numberOfTapsRequired    = 1;
	[self addGestureRecognizer:self.singleTap];
	
	// 双击(播放/暂停)
	self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
	self.doubleTap.delegate                = self;
	self.doubleTap.numberOfTouchesRequired = 1; //手指数
	self.doubleTap.numberOfTapsRequired    = 2;
	[self addGestureRecognizer:self.doubleTap];
	
	// 解决点击当前view时候响应其他控件事件
	[self.singleTap setDelaysTouchesBegan:YES];
	[self.doubleTap setDelaysTouchesBegan:YES];
	// 双击失败响应单击事件
	[self.singleTap requireGestureRecognizerToFail:self.doubleTap];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.isAutoPlay) {
		UITouch *touch = [touches anyObject];
		if(touch.tapCount == 1) {
			[self performSelector:@selector(singleTapAction:) withObject:@(NO) ];
		} else if (touch.tapCount == 2) {
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction:) object:nil];
			[self doubleTapAction:touch.gestureRecognizers.lastObject];
		}
	}
}

- (void)createTimer {
	__weak typeof(self) weakSelf = self;
	self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
		AVPlayerItem *currentItem = weakSelf.playerItem;
		NSArray *loadedRanges = currentItem.seekableTimeRanges;
		if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
			NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
			weakSelf.playerModel.currentTime = currentTime;
			CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
			CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
			weakSelf.currentTime = currentTime;
			[weakSelf.controlView zf_playerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
		}
	}];
}

/**
 *  获取系统音量
 */
- (void)configureVolume {
	MPVolumeView *volumeView = [[MPVolumeView alloc] init];
	_volumeViewSlider = nil;
	for (UIView *view in [volumeView subviews]){
		if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
			_volumeViewSlider = (UISlider *)view;
			break;
		}
	}
	
	// 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
	NSError *setCategoryError = nil;
	BOOL success = [[AVAudioSession sharedInstance]
			setCategory: AVAudioSessionCategoryPlayback
			error: &setCategoryError];
	
	if (!success) { /* handle the error in setCategoryError */ }
	
}

/**
 *  耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
	NSDictionary *interuptionDict = notification.userInfo;
	
	NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
	
	switch (routeChangeReason) {
			
		case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
			// 耳机插入
			break;
			
		case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
		{
			// 耳机拔掉
			// 拔掉耳机继续播放
			[self play];
		}
			break;
			
		case AVAudioSessionRouteChangeReasonCategoryChange:
			// called at start - also when other audio wants to play
			NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
			break;
	}
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.player.currentItem) {
		if ([keyPath isEqualToString:@"status"]) {
			
			if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
				[self setNeedsLayout];
				[self layoutIfNeeded];
				// 添加playerLayer到self.layer
				[self.layer insertSublayer:self.playerLayer atIndex:0];
				self.state = ZFPlayerStatePlaying;
				// 加载完成后，再添加平移手势
				// 添加平移手势，用来控制音量、亮度、快进快退
				UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
				panRecognizer.delegate = self;
				[panRecognizer setMaximumNumberOfTouches:1];
				[panRecognizer setDelaysTouchesBegan:YES];
				[panRecognizer setDelaysTouchesEnded:YES];
				[panRecognizer setCancelsTouchesInView:YES];
				[self addGestureRecognizer:panRecognizer];
				
				// 跳到xx秒播放视频
				if (self.seekTime) {
					[self seekToTime:self.seekTime completionHandler:nil];
				}
				self.player.muted = self.mute;
			} else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
				self.state = ZFPlayerStateFailed;
			}
		} else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
			
			// 计算缓冲进度
			NSTimeInterval timeInterval = [self availableDuration];
			CMTime duration             = self.playerItem.duration;
			CGFloat totalDuration       = CMTimeGetSeconds(duration);
			[self.controlView zf_playerSetProgress:timeInterval / totalDuration];
			
		} else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
			
			// 当缓冲是空的时候
			if (self.playerItem.playbackBufferEmpty) {
				self.state = ZFPlayerStateBuffering;
				[self bufferingSomeSecond];
			}
			
		} else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
			
			// 当缓冲好的时候
			if (self.playerItem.playbackLikelyToKeepUp && self.state == ZFPlayerStateBuffering){
				self.state = ZFPlayerStatePlaying;
			}
		}
	} else if (object == self.scrollView) {
		if ([keyPath isEqualToString:kZFPlayerViewContentOffset]) {
			if (self.isFullScreen) { return; }
			// 当tableview滚动时处理playerView的位置
			[self handleScrollOffsetWithDict:change];
		} else if ([keyPath isEqualToString:kZFPlayerViewFrame]) {
			if (self.isFullScreen) {
				return;
			}
			CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
			UIView *window = [UIApplication sharedApplication].keyWindow;
			if ( !CGRectContainsRect(window.bounds, newFrame) )
			{
				[self resetPlayer];
			}
		}
	} else if (object == self.judgeScrollView) {
		if ([keyPath isEqualToString:kZFPlayerViewContentOffset]) {
			if (self.isFullScreen) { return; }
			
			CGRect superRect = self.judgeScrollView.bounds;
			if ( !CGRectContainsRect(superRect, self.scrollView.frame) ) {
				[self resetPlayer];
			}
		} else if ([keyPath isEqualToString:kZFPlayerViewFrame]) {
			if (self.isFullScreen) {
				return;
			}
			CGRect superRect = self.judgeScrollView.bounds;
			if ( !CGRectContainsRect(superRect, self.scrollView.frame) ) {
				[self resetPlayer];
			}
		}
	}
}

#pragma mark - tableViewContentOffset

/**
 *  KVO TableViewContentOffset
 *
 *  @param dict void
 */
- (void)handleScrollOffsetWithDict:(NSDictionary*)dict {
	if ([self.scrollView isKindOfClass:[UITableView class]]) {
		UITableView *tableView = (UITableView *)self.scrollView;
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
		NSArray *visableCells = tableView.visibleCells;
		if ([visableCells containsObject:cell]) {
			// 在显示中
			[self updatePlayerViewToCell];
		} else {
			if (self.stopPlayWhileCellNotVisable) {
				[self resetPlayer];
			} else {
				// 在底部
				[self updatePlayerViewToBottom];
			}
		}
	} else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
		UICollectionView *collectionView = (UICollectionView *)self.scrollView;
		UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
		if ( [collectionView.visibleCells containsObject:cell]) {
			// 在显示中
			[self updatePlayerViewToCell];
		} else {
			if (self.stopPlayWhileCellNotVisable) {
				[self resetPlayer];
			} else {
				// 在底部
				[self updatePlayerViewToBottom];
			}
		}
	}
}

/**
 *  缩小到底部，显示小视频
 */
- (void)updatePlayerViewToBottom {
	if (self.isBottomVideo) { return; }
	self.isBottomVideo = YES;
	[self.controlView zf_showBarrangeView:NO];
	if (self.playDidEnd) { // 如果播放完了，滑动到小屏bottom位置时，直接resetPlayer
		self.repeatToPlay = NO;
		self.playDidEnd   = NO;
		[self resetPlayer];
		return;
	}
	[[UIApplication sharedApplication].keyWindow addSubview:self];
	
	if (CGPointEqualToPoint(self.shrinkRightBottomPoint, CGPointZero)) { // 没有初始值
		CGPoint startPoint = CGPointMake(10, self.scrollView.contentInset.bottom+10);
		[self setShrinkRightBottomPoint:startPoint resetSize:YES];
	} else {
		[self setShrinkRightBottomPoint:self.shrinkRightBottomPoint resetSize:NO];
	}
	// 小屏播放
	[self.controlView zf_playerBottomShrinkPlay];
}

/**
 *  回到cell显示
 */
- (void)updatePlayerViewToCell {
	
	if (!self.isBottomVideo) { return; }
	self.shrinkRightBottomPoint = CGPointZero;
	[self.controlView zf_showBarrangeView:YES];
	self.isBottomVideo = NO;
	[self setOrientationPortraitConstraint];
	[self.controlView zf_playerCellPlay];
}

/**
 *  设置横屏的约束
 */
- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
//	self.isFullScreen = YES;
//	[self toOrientation:orientation];
}

/**
 *  设置竖屏的约束
 */
- (void)setOrientationPortraitConstraint {
	if (self.isCellVideo) {
		if ([self.scrollView isKindOfClass:[UITableView class]]) {
			UITableView *tableView = (UITableView *)self.scrollView;
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
			self.isBottomVideo = NO;
			if (![tableView.visibleCells containsObject:cell]) {
				[self updatePlayerViewToBottom];
			} else {
				UIView *fatherView = [cell.contentView viewWithTag:self.playerModel.fatherViewTag];
				[self addPlayerToFatherView:fatherView];
			}
		} else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
			UICollectionView *collectionView = (UICollectionView *)self.scrollView;
			UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
			self.isBottomVideo = NO;
			if (![collectionView.visibleCells containsObject:cell]) {
				[self updatePlayerViewToBottom];
			} else {
				UIView *fatherView = [cell viewWithTag:self.playerModel.fatherViewTag];
				[self addPlayerToFatherView:fatherView];
			}
		}
	} else {
		[self addPlayerToFatherView:self.playerModel.fatherView];
	}
	
	[self toOrientation:UIInterfaceOrientationPortrait];
}

- (void)presentFullScreenController
{
	if (self.isFullScreen) {
		return;
	}
	UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.zf_currentViewController;
	if (topViewController == self.fullScreenViewController || topViewController.presentedViewController == self.fullScreenViewController) {
		return;
	}
	self.isFullScreen = YES;
	[self addPlayerToFatherView:self.fullScreenViewController.view];
	[topViewController presentViewController:self.fullScreenViewController animated:YES completion:nil];
}
- (void)dismissFullScreenController {
	self.isFullScreen = NO;
	[self.fullScreenViewController dismissViewControllerAnimated:YES completion:^{
		// 设置竖屏 约束
		[self _ResetVideoCellScrollView];
	}];
}
- (void)toOrientation:(UIInterfaceOrientation)orientation {
	
//	/// 全屏用 fullScreenController  不进行 view 视图旋转
//	if (self.isFullScreen && UIInterfaceOrientationIsLandscape(orientation)) {
//		return;
//	}
//	
//	
//	// 获取到当前状态条的方向
//	UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//	// 判断如果当前方向和要旋转的方向一致,那么不做任何操作
//	if (currentOrientation == orientation) { return; }
//	
//	// 根据要旋转的方向,使用Masonry重新修改限制
//	if (orientation != UIInterfaceOrientationPortrait) {//
//							    // 这个地方加判断是为了从全屏的一侧,直接到全屏的另一侧不用修改限制,否则会出错;
//		if (currentOrientation == UIInterfaceOrientationPortrait) {
//			[self removeFromSuperview];
//			ZFBrightnessView *brightnessView = [ZFBrightnessView sharedBrightnessView];
//			[[UIApplication sharedApplication].keyWindow insertSubview:self belowSubview:brightnessView];
//			[self mas_remakeConstraints:^(MASConstraintMaker *make) {
//				make.width.equalTo(@(ScreenHeight));
//				make.height.equalTo(@(ScreenWidth));
//				make.center.equalTo([UIApplication sharedApplication].keyWindow);
//			}];
//		}
//	}
//	
//	// iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
//	// 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
//	[[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
//	// 获取旋转状态条需要的时间:
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:0.3];
//	// 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
//	// 给你的播放视频的view视图设置旋转
//	self.transform = CGAffineTransformIdentity;
//	self.transform = [self getTransformRotationAngle];
//	// 开始旋转
//	[UIView commitAnimations];
}

/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle {
//	// 状态条的方向已经设置过,所以这个就是你想要旋转的方向
//	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//	// 根据要进行旋转的方向来计算旋转的角度
//	if (orientation == UIInterfaceOrientationPortrait) {
//		return CGAffineTransformIdentity;
//	} else if (orientation == UIInterfaceOrientationLandscapeLeft){
//		return CGAffineTransformMakeRotation(-M_PI_2);
//	} else if(orientation == UIInterfaceOrientationLandscapeRight){
//		return CGAffineTransformMakeRotation(M_PI_2);
//	}
	return CGAffineTransformIdentity;
}

#pragma mark 屏幕转屏相关

/**
 *  屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
//	if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
//		// 设置横屏
//		[self setOrientationLandscapeConstraint:orientation];
//
//	} else if (orientation == UIInterfaceOrientationPortrait) {
//		// 设置竖屏
//		[self setOrientationPortraitConstraint];
//	}
}

/**
 *  屏幕方向发生变化会调用这里
 */
- (void)onDeviceOrientationChange {
	if (!self.player) { return; }
	if (ZFPlayerShared.isLockScreen) { return; }
	if (self.didEnterBackground) { return; };
	if (self.playerPushedOrPresented) { return; }
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
	if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown ) { return; }
	
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortraitUpsideDown:{
		}
			break;
		case UIInterfaceOrientationPortrait:{
			if (self.isFullScreen) {
				[self dismissFullScreenController];
			}
		}
			break;
		case UIInterfaceOrientationLandscapeLeft:{
			if (self.isFullScreen == NO) {
				[self presentFullScreenController];
			}
		}
			break;
		case UIInterfaceOrientationLandscapeRight:{
			if (self.isFullScreen == NO) {
				[self presentFullScreenController];
			}
		}
			break;
		default:
			break;
	}
}

// 状态条变化通知（在前台播放才去处理）
- (void)onStatusBarOrientationChange {
	if (!self.didEnterBackground) {
		// 获取到当前状态条的方向
		UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
		if (currentOrientation == UIInterfaceOrientationPortrait) {
			
			[self.brightnessView removeFromSuperview];
			UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
			[keyWindow addSubview:self.brightnessView];
			[self.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
				make.width.height.mas_equalTo(155);
				make.center.equalTo(keyWindow);
			}];
		} else {
			[self.brightnessView removeFromSuperview];
			[self addSubview:self.brightnessView];
			[self.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
				make.center.mas_equalTo(self);
				make.width.height.mas_equalTo(155);
			}];
		}
	}
}

- (void)_ResetVideoCellScrollView
{
	[self setOrientationPortraitConstraint];
	if (self.cellPlayerOnCenter) {
		if ([self.scrollView isKindOfClass:[UITableView class]]) {
			UITableView *tableView = (UITableView *)self.scrollView;
			[tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
			
		} else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
			UICollectionView *collectionView = (UICollectionView *)self.scrollView;
			[collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
		}
	}
}

/**
 *  锁定屏幕方向按钮
 *
 *  @param sender UIButton
 */
- (void)lockScreenAction:(UIButton *)sender {
	sender.selected             = !sender.selected;
	self.isLocked               = sender.selected;
	// 调用AppDelegate单例记录播放状态是否锁屏，在TabBarController设置哪些页面支持旋转
	ZFPlayerShared.isLockScreen = sender.selected;
}

/**
 *  解锁屏幕方向锁定
 */
- (void)unLockTheScreen {
	// 调用AppDelegate单例记录播放状态是否锁屏
	ZFPlayerShared.isLockScreen = NO;
	[self.controlView zf_playerLockBtnState:NO];
	self.isLocked = NO;
	[self interfaceOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
	self.state = ZFPlayerStateBuffering;
	// playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
	__block BOOL isBuffering = NO;
	if (isBuffering) return;
	isBuffering = YES;
	
	// 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
	[self.player pause];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		// 如果此时用户已经暂停了，则不再需要开启播放了
		if (self.isPauseByUser) {
			isBuffering = NO;
			return;
		}
		
		[self play];
		// 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
		isBuffering = NO;
		if (!self.playerItem.isPlaybackLikelyToKeepUp) { [self bufferingSomeSecond]; }
		
	});
}

#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
	NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
	CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
	float startSeconds        = CMTimeGetSeconds(timeRange.start);
	float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
	NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
	return result;
}

#pragma mark - Action

/**
 *   轻拍方法
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)singleTapAction:(UIGestureRecognizer *)gesture {
	if ([gesture isKindOfClass:[NSNumber class]] && ![(id)gesture boolValue]) {
		[self _fullScreenAction];
		return;
	}
	if (gesture.state == UIGestureRecognizerStateRecognized) {
		if (self.isBottomVideo && !self.isFullScreen) { [self _fullScreenAction]; }
		else {
			if (self.playDidEnd) { return; }
			else {
				[self.controlView zf_playerShowOrHideControlView];
			}
		}
	}
}

/**
 *  双击播放/暂停
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)doubleTapAction:(UIGestureRecognizer *)gesture {
	if (self.playDidEnd) { return;  }
	// 显示控制层
	[self.controlView zf_playerShowControlView];
	if (self.isPauseByUser) { [self play]; }
	else { [self pause]; }
	if (!self.isAutoPlay) {
		self.isAutoPlay = YES;
		[self configZFPlayer];
	}
}


- (void)shrikPanAction:(UIPanGestureRecognizer *)gesture {
	CGPoint point = [gesture locationInView:[UIApplication sharedApplication].keyWindow];
	ZFPlayerView *view = (ZFPlayerView *)gesture.view;
	
	
	if (gesture.state == UIGestureRecognizerStateEnded) {
		[self judgeViewPoint:point view:view];
		
	} else {
		view.center = point;
		CGPoint centerPoint = CGPointMake(ScreenWidth - view.frame.origin.x- view.frame.size.width, ScreenHeight - view.frame.origin.y-view.frame.size.height);
		[self setShrinkRightBottomPoint:centerPoint resetSize:NO];
	}
}
- (void)judgeViewPoint:(CGPoint)point view:(UIView *)view
{
	const CGFloat width = view.frame.size.width;
	const CGFloat height = view.frame.size.height;
	const CGFloat distance = 10;  // 离四周的最小边距
				      // x轴的的移动
	if (point.x < width/2) {
		point.x = width/2 + distance;
	} else if (point.x > ScreenWidth - width/2) {
		point.x = ScreenWidth - width/2 - distance;
	}
	// y轴的移动
	if (point.y < height/2) {
		point.y = height/2 + distance;
	} else if (point.y > ScreenHeight - height/2) {
		point.y = ScreenHeight - height/2 - distance;
	}
	
	[UIView animateWithDuration:0.5 animations:^{
		view.center = point;
		CGPoint shrinkPoint = CGPointMake(ScreenWidth - view.frame.origin.x - width, ScreenHeight - view.frame.origin.y - height);
		[self setShrinkRightBottomPoint:shrinkPoint resetSize:NO];
	}];
}
- (void)shrinkPinchAction:(UIPinchGestureRecognizer *)gesture {
	
	CGPoint point = [gesture locationInView:[UIApplication sharedApplication].keyWindow];
	ZFPlayerView *view = (ZFPlayerView *)gesture.view;
	NSUInteger touches = [gesture numberOfTouches];
	
	if (gesture.state == UIGestureRecognizerStateEnded)
	{
		[self judgeViewPoint:point view:view];
	}
	else
	{
		if (touches == 2)
		{
			CGFloat scale = gesture.scale;
			CGRect frame = view.frame;
			CGFloat minWidth = ScreenWidth * 0.5 - 20;
			CGFloat width = frame.size.width * scale;
			if ( width > ScreenWidth || width < minWidth) {
				return;
			}
			frame.size.width =  width;
			frame.size.height = frame.size.height * scale;
			
			frame.origin.x = frame.origin.x - (frame.size.width - view.frame.size.width) * 0.5;
			frame.origin.y = frame.origin.y - (frame.size.height - view.frame.size.height) * 0.5;
			
			view.frame = frame;
		}
	}
	
}

/** 全屏 */
- (void)_fullScreenAction {
	if (ZFPlayerShared.isLockScreen) {
		[self unLockTheScreen];
		return;
	}
	
	if (self.isFullScreen) {
		ZFPlayerShared.isLandscape = NO;
		[self dismissFullScreenController];
		return;
	} else {
		ZFPlayerShared.isLandscape = YES;
		
		[self presentFullScreenController];
	}
}

#pragma mark - NSNotification Action

/**
 *  播放完了
 *
 *  @param notification 通知
 */
- (void)PlayDidEnd:(NSNotification *)notification {
	self.state = ZFPlayerStateStopped;
	if (self.isBottomVideo && !self.isFullScreen) { // 播放完了，如果是在小屏模式 && 在bottom位置，直接关闭播放器
		self.repeatToPlay = NO;
		self.playDidEnd   = NO;
		[self resetPlayer];
	} else {
		if (!self.isDragged) { // 如果不是拖拽中，直接结束播放
			self.playDidEnd = YES;
			[self.controlView zf_playerPlayEnd];
		}
	}
}

/**
 *  应用退到后台
 */
- (void)appDidEnterBackground {
	self.didEnterBackground     = YES;
	// 退到后台锁定屏幕方向
	ZFPlayerShared.isLockScreen = YES;
	[_player pause];
	self.state                  = ZFPlayerStatePause;
}

/**
 *  应用进入前台
 */
- (void)appDidEnterPlayground {
	self.didEnterBackground     = NO;
	// 根据是否锁定屏幕方向 来恢复单例里锁定屏幕的方向
	ZFPlayerShared.isLockScreen = self.isLocked;
	if (!self.isPauseByUser) {
		self.state         = ZFPlayerStatePlaying;
		self.isPauseByUser = NO;
		[self play];
	}
}

/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler {
	if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
		// seekTime:completionHandler:不能精确定位
		// 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
		// 转换成CMTime才能给player来控制播放进度
		[self.controlView zf_playerActivity:YES];
		[self.player pause];
		CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
		__weak typeof(self) weakSelf = self;
		[self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
			[weakSelf.controlView zf_playerActivity:NO];
			// 视频跳转回调
			if (completionHandler) { completionHandler(finished); }
			[weakSelf.player play];
			weakSelf.seekTime = 0;
			weakSelf.isDragged = NO;
			// 结束滑动
			[weakSelf.controlView zf_playerDraggedEnd];
			if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !weakSelf.isLocalVideo) { weakSelf.state = ZFPlayerStateBuffering; }
			
		}];
	}
}

#pragma mark - UIPanGestureRecognizer手势方法

/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan {
	//根据在view上Pan的位置，确定是调音量还是亮度
	CGPoint locationPoint = [pan locationInView:self];
	
	// 我们要响应水平移动和垂直移动
	// 根据上次和本次移动的位置，算出一个速率的point
	CGPoint veloctyPoint = [pan velocityInView:self];
	
	// 判断是垂直移动还是水平移动
	switch (pan.state) {
		case UIGestureRecognizerStateBegan:{ // 开始移动
						     // 使用绝对值来判断移动的方向
			CGFloat x = fabs(veloctyPoint.x);
			CGFloat y = fabs(veloctyPoint.y);
			if (x > y) { // 水平移动
				     // 取消隐藏
				self.panDirection = PanDirectionHorizontalMoved;
				// 给sumTime初值
				CMTime time       = self.player.currentTime;
				self.sumTime      = time.value/time.timescale;
			}
			else if (x < y){ // 垂直移动
				self.panDirection = PanDirectionVerticalMoved;
				// 开始滑动的时候,状态改为正在控制音量
				if (locationPoint.x > self.bounds.size.width / 2) {
					self.isVolume = YES;
				}else { // 状态改为显示亮度调节
					self.isVolume = NO;
				}
			}
			break;
		}
		case UIGestureRecognizerStateChanged:{ // 正在移动
			switch (self.panDirection) {
				case PanDirectionHorizontalMoved:{
					[self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
					break;
				}
				case PanDirectionVerticalMoved:{
					[self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
					break;
				}
				default:
					break;
			}
			break;
		}
		case UIGestureRecognizerStateEnded:{ // 移动停止
						     // 移动结束也需要判断垂直或者平移
						     // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
			switch (self.panDirection) {
				case PanDirectionHorizontalMoved:{
					self.isPauseByUser = NO;
					[self seekToTime:self.sumTime completionHandler:nil];
					// 把sumTime滞空，不然会越加越多
					self.sumTime = 0;
					break;
				}
				case PanDirectionVerticalMoved:{
					// 垂直移动结束后，把状态改为不再控制音量
					self.isVolume = NO;
					break;
				}
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
}

/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value {
	self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value {
	// 每次滑动需要叠加时间
	self.sumTime += value / 200;
	
	// 需要限定sumTime的范围
	CMTime totalTime           = self.playerItem.duration;
	CGFloat totalDuration = (CGFloat)totalTime.value/totalTime.timescale;
	if (self.sumTime > totalDuration) { self.sumTime = totalDuration;}
	if (self.sumTime < 0) { self.sumTime = 0; }
	
	BOOL style = false;
	if (value > 0) { style = YES; }
	if (value < 0) { style = NO; }
	if (value == 0) { return; }
	
	self.isDragged = YES;
	[self.controlView zf_playerDraggedTime:self.sumTime totalTime:totalDuration isForward:style hasPreview:NO];
}

/**
 *  根据时长求出字符串
 *
 *  @param time 时长
 *
 *  @return 时长字符串
 */
- (NSString *)durationStringWithTime:(int)time {
	// 获取分钟
	NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
	// 获取秒数
	NSString *sec = [NSString stringWithFormat:@"%02d",time % 60];
	return [NSString stringWithFormat:@"%@:%@", min, sec];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	
	if (gestureRecognizer == self.shrinkPanGesture && self.isCellVideo) {
		if (!self.isBottomVideo || self.isFullScreen) {
			return NO;
		}
	}
	if (gestureRecognizer == self.shrinkPinchGesture && self.isCellVideo) {
		if (!self.isBottomVideo || self.isFullScreen) {
			return NO;
		}
	}
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && gestureRecognizer != self.shrinkPanGesture) {
		if ((self.isCellVideo && !self.isFullScreen) || self.playDidEnd || self.isLocked){
			return NO;
		}
	}
	if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
		if (self.isBottomVideo && !self.isFullScreen) {
			return NO;
		}
	}
	if ([touch.view isKindOfClass:[UISlider class]]) {
		return NO;
	}
	
	return YES;
}

#pragma mark - Setter

/**
 *  videoURL的setter方法
 *
 *  @param videoURL videoURL
 */
- (void)setVideoURL:(NSURL *)videoURL {
	_videoURL = videoURL;
	
	// 每次加载视频URL都设置重播为NO
	self.repeatToPlay = NO;
	self.playDidEnd   = NO;
	
	// 添加通知
	[self addNotifications];
	
	self.isPauseByUser = YES;
	
	// 添加手势
	[self createGesture];
	
}

/**
 *  设置播放的状态
 *
 *  @param state ZFPlayerState
 */
- (void)setState:(ZFPlayerState)state {
	_state = state;
	/// 屏幕不常亮
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
	// 控制菊花显示、隐藏
	[self.controlView zf_playerActivity:state == ZFPlayerStateBuffering];
	if (state == ZFPlayerStatePlaying || state == ZFPlayerStateBuffering) {
		/// 屏幕常亮
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		// 隐藏占位图
		[self.controlView zf_playerItemPlaying];
	} else if (state == ZFPlayerStateFailed) {
		NSError *error = [self.playerItem error];
		[self.controlView zf_playerItemStatusFailed:error];
	}
}

/**
 *  根据playerItem，来添加移除观察者
 *
 *  @param playerItem playerItem
 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
	if (_playerItem == playerItem) {return;}
	@try {
		if (_playerItem) {
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
			[_playerItem removeObserver:self forKeyPath:@"status"];
			[_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
			[_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
			[_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
		}
		_playerItem = playerItem;
		if (playerItem) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
			[playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
			[playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
			// 缓冲区空了，需要等待数据
			[playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
			// 缓冲区有足够数据可以播放了
			[playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
		}
		
	} @catch (NSException *exception) {
		
	} @finally {
		
	}
}

/**
 *  根据tableview的值来添加、移除观察者
 *
 *  @param scrollView tableView
 */
- (void)setScrollView:(UIScrollView *)scrollView {
	if (_scrollView == scrollView) { return; }
	@try {
		if (_scrollView) {
			[_scrollView removeObserver:self forKeyPath:kZFPlayerViewContentOffset];
			[_scrollView removeObserver:self forKeyPath:kZFPlayerViewFrame];
		}
		_scrollView = scrollView;
		if (scrollView) {
			[scrollView addObserver:self forKeyPath:kZFPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
			[scrollView addObserver:self forKeyPath:kZFPlayerViewFrame options:(NSKeyValueObservingOptionNew) context:nil];
		}
		
	} @catch (NSException *exception) {
		
	} @finally {
		
	}
}
- (void)setJudgeScrollView:(UIScrollView *)judgeScrollView
{
	if (_judgeScrollView == judgeScrollView) { return; }
	@try {
		if (_judgeScrollView) {
			[_judgeScrollView removeObserver:self forKeyPath:kZFPlayerViewContentOffset];
			[_judgeScrollView removeObserver:self forKeyPath:kZFPlayerViewFrame];
		}
		_judgeScrollView = judgeScrollView;
		if (_judgeScrollView) {
			[_judgeScrollView addObserver:self forKeyPath:kZFPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
			[_judgeScrollView addObserver:self forKeyPath:kZFPlayerViewFrame options:(NSKeyValueObservingOptionNew) context:nil];
		}
		
	} @catch (NSException *exception) {
		
	} @finally {
		
	}
}

/**
 *  设置playerLayer的填充模式
 *
 *  @param playerLayerGravity playerLayerGravity
 */
- (void)setPlayerLayerGravity:(ZFPlayerLayerGravity)playerLayerGravity {
	_playerLayerGravity = playerLayerGravity;
	self.playerLayer.videoGravity = self.videoGravity;
}

/**
 *  是否有下载功能
 */
- (void)setHasDownload:(BOOL)hasDownload {
	_hasDownload = hasDownload;
	[self.controlView zf_playerHasDownloadFunction:hasDownload];
}

- (void)setResolutionDic:(NSDictionary *)resolutionDic {
	_resolutionDic = resolutionDic;
	self.videoURLArray = [resolutionDic allValues];
}

- (void)setControlView:(UIView *)controlView {
	if (_controlView) { return; }
	_controlView = controlView;
	controlView.delegate = self;
	[self addSubview:controlView];
	[controlView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.mas_equalTo(UIEdgeInsetsZero);
	}];
}

- (void)setPlayerModel:(ZFPlayerModel *)playerModel {
	_playerModel = playerModel;
	
	if (playerModel.seekTime) { self.seekTime = playerModel.seekTime; }
	[self.controlView zf_playerModel:playerModel];
	// 分辨率
	if (playerModel.resolutionDic) {
		self.resolutionDic = playerModel.resolutionDic;
	}
	
	if (playerModel.scrollView && playerModel.indexPath && playerModel.videoURL) {
		NSCAssert(playerModel.fatherViewTag, @"请指定playerViews所在的faterViewTag");
		[self cellVideoWithScrollView:playerModel.scrollView AtIndexPath:playerModel.indexPath];
		if ([self.scrollView isKindOfClass:[UITableView class]]) {
			UITableView *tableView = (UITableView *)playerModel.scrollView;
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:playerModel.indexPath];
			UIView *fatherView = [cell.contentView viewWithTag:playerModel.fatherViewTag];
			[self addPlayerToFatherView:fatherView];
		} else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
			UICollectionView *collectionView = (UICollectionView *)playerModel.scrollView;
			UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:playerModel.indexPath];
			UIView *fatherView = [cell.contentView viewWithTag:playerModel.fatherViewTag];
			[self addPlayerToFatherView:fatherView];
		}
	} else {
		NSCAssert(playerModel.fatherView, @"请指定playerView的faterView");
		[self addPlayerToFatherView:playerModel.fatherView];
	}
	self.videoURL = playerModel.videoURL;
}

- (void)setShrinkRightBottomPoint:(CGPoint)shrinkRightBottomPoint resetSize:(BOOL)reset {
	_shrinkRightBottomPoint = shrinkRightBottomPoint;
	CGFloat width = self.bounds.size.width;
	CGFloat height = (self.bounds.size.height / self.bounds.size.width);
	if (reset) {
		width = ScreenWidth*0.5-20;
	}
	[self mas_remakeConstraints:^(MASConstraintMaker *make) {
		make.width.mas_equalTo(width);
		make.height.equalTo(self.mas_width).multipliedBy(height);
		make.trailing.mas_equalTo(-shrinkRightBottomPoint.x);
		make.bottom.mas_equalTo(-shrinkRightBottomPoint.y);
	}];
}

- (void)setPlayerPushedOrPresented:(BOOL)playerPushedOrPresented {
	_playerPushedOrPresented = playerPushedOrPresented;
	if (playerPushedOrPresented) {
		[self pause];
	} else {
		[self play];
	}
}
- (void)setShowKeyboardView:(BOOL)showKeyboardView
{
	_showKeyboardView = showKeyboardView;
	if (self.isFullScreen || !self.superview) {
		return;
	}
	self.fieldView.hidden = !showKeyboardView;
	
	if (showKeyboardView) {
		
		UIView *superView = self.superview;
		[superView addSubview:self.fieldView];
		
		[self mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.top.leading.trailing.equalTo(superView);
		}];
		[self.fieldView mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.mas_bottom);
			make.leading.trailing.bottom.equalTo(superView);
			make.height.mas_equalTo(self.keyBoradViewHeight < 1 ? 48.0 : self.keyBoradViewHeight);
		}];
	}
	else
	{
		[self.fieldView removeFromSuperview];
		[self mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.mas_equalTo(UIEdgeInsetsZero);
		}];
	}
	self.fieldView.hidden = !showKeyboardView;
	
}
#pragma mark - Getter

- (AVAssetImageGenerator *)imageGenerator {
	if (!_imageGenerator) {
		_imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.urlAsset];
	}
	return _imageGenerator;
}

- (ZFBrightnessView *)brightnessView {
	if (!_brightnessView) {
		_brightnessView = [ZFBrightnessView sharedBrightnessView];
	}
	return _brightnessView;
}

- (NSString *)videoGravity {
	switch (self.playerLayerGravity) {
		case ZFPlayerLayerGravityResize:
			_videoGravity = AVLayerVideoGravityResize;
			break;
		case ZFPlayerLayerGravityResizeAspect:
			_videoGravity = AVLayerVideoGravityResizeAspect;
			break;
		case ZFPlayerLayerGravityResizeAspectFill:
			_videoGravity = AVLayerVideoGravityResizeAspectFill;
			break;
		default:
			_videoGravity = AVLayerVideoGravityResizeAspectFill;
			break;
	}
	return _videoGravity;
}

- (DMKeyboardView *)keyBoardView
{
	if (_keyBoardView == nil) {
		_keyBoardView = [DMKeyboardView keyboardView];
		_keyBoardView.type = DMBarrageTypeLandscape;
		__weak __typeof(self)weakSelf = self;
		__weak __typeof(_keyBoardView)weakKeyBoardView = _keyBoardView;
		[_keyBoardView setHandleSendBarrageCallBack:^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString, NSInteger playTime, 	DMCanSendBarrage canSend) {
			__strong __typeof(weakSelf)strongSelf = weakSelf;
			
			if (strongSelf.playerModel.sendBarrangeText) {
				
				BOOL res = strongSelf.playerModel.sendBarrangeText(strongSelf.playerModel, showTipView, editString, strongSelf.playerModel.currentTime, ^(BOOL res) {
					if (canSend) {
						canSend(res);
					}
					if (res) {
						[strongSelf.controlView zf_receiveBarrangeData:[DMBarrageData sendBarrangeWithText:editString]];
					}
				});
				
				if (res) {
					[strongSelf.controlView zf_receiveBarrangeData:[DMBarrageData sendBarrangeWithText:editString]];
				}
			}
			return YES;
		}];
		
		[_keyBoardView setTextFieldBeginEditCallBack:^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString) {
			__strong __typeof(weakSelf)strongSelf = weakSelf;
			if (strongSelf.playerModel.editFilter) {
				return strongSelf.playerModel.editFilter(strongSelf.playerModel,showTipView,editString);
			}
			return YES;
		}];
		[_keyBoardView setDismissCallBack:^{
			__strong __typeof(weakSelf)strongSelf = weakSelf;
			__strong __typeof(weakKeyBoardView)strongKeyBoardView= weakKeyBoardView;
			strongKeyBoardView.hidden = YES;
			if (!strongSelf.isPauseByUser) {
				[strongSelf play];
			}
		}];
		
	}
	return _keyBoardView;
}
- (DMBarrageIFieldView *)fieldView
{
	if (_fieldView == nil) {
		_fieldView = [[DMBarrageIFieldView alloc] init];
		_fieldView.type = DMBarrageTypeOptional;
		__weak __typeof(self)weakSelf = self;
		[_fieldView setHandleSendBarrageCallBack:^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString, NSInteger playTime, DMCanSendBarrage canSend) {
			__strong __typeof(weakSelf)strongSelf = weakSelf;
			if (strongSelf.playerModel.sendBarrangeText) {
				
				BOOL res = strongSelf.playerModel.sendBarrangeText(strongSelf.playerModel, nil, editString, strongSelf.playerModel.currentTime, ^(BOOL res) {
					if (canSend) {
						canSend(res);
					}
					if (res) {
						[strongSelf.controlView zf_receiveBarrangeData:[DMBarrageData sendBarrangeWithText:editString]];
					}
				});
				
				if (res) {
					[strongSelf.controlView zf_receiveBarrangeData:[DMBarrageData sendBarrangeWithText:editString]];
				}
			}
			return YES;
		}];
		
		[_fieldView setTextFieldBeginEditCallBack:^BOOL(ZFPlayerModel *model, UIView *showTipView, NSString *editString) {
			__strong __typeof(weakSelf)strongSelf = weakSelf;
			if (strongSelf.playerModel.editFilter) {
				return strongSelf.playerModel.editFilter(strongSelf.playerModel, nil, editString);
			}
			return YES;
		}];
	}
	return _fieldView;
}
- (ZFFullScreenViewController *)fullScreenViewController
{
	if (_fullScreenViewController == nil) {
		_fullScreenViewController = [[ZFFullScreenViewController alloc] init];
	}
	return _fullScreenViewController;
}
#pragma mark - ZFPlayerControlViewDelegate

- (void)zf_controlView:(UIView *)controlView playAction:(UIButton *)sender {
	self.isPauseByUser = !self.isPauseByUser;
	if (self.isPauseByUser) {
		[self pause];
		if (self.state == ZFPlayerStatePlaying) { self.state = ZFPlayerStatePause;}
	} else {
		[self play];
		if (self.state == ZFPlayerStatePause) { self.state = ZFPlayerStatePlaying; }
	}
	
	if (!self.isAutoPlay) {
		self.isAutoPlay = YES;
		[self configZFPlayer];
	}
}

- (void)zf_controlView:(UIView *)controlView backAction:(UIButton *)sender {
	if (ZFPlayerShared.isLockScreen) {
		[self unLockTheScreen];
	} else {
		if (!self.isFullScreen) {
			// player加到控制器上，只有一个player时候
			[self pause];
			if ([self.delegate respondsToSelector:@selector(zf_playerBackAction)]) { [self.delegate zf_playerBackAction]; }
		} else {
			[self dismissFullScreenController];
		}
	}
}

- (void)zf_controlView:(UIView *)controlView closeAction:(UIButton *)sender {
	[self resetPlayer];
	[self removeFromSuperview];
}

- (void)zf_controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender {
	[self _fullScreenAction];
}

- (void)zf_controlView:(UIView *)controlView lockScreenAction:(UIButton *)sender {
	self.isLocked               = sender.selected;
	// 调用AppDelegate单例记录播放状态是否锁屏
	ZFPlayerShared.isLockScreen = sender.selected;
}

- (void)zf_controlView:(UIView *)controlView cneterPlayAction:(UIButton *)sender {
	if (self.state == ZFPlayerStatePlaying) {
		[self pause];
	}
	else if (self.state == ZFPlayerStatePause) {
		[self play];
	}
 	else {
		[self configZFPlayer];
	}
}

- (void)zf_controlView:(UIView *)controlView repeatPlayAction:(UIButton *)sender {
	// 没有播放完
	self.playDidEnd   = NO;
	// 重播改为NO
	self.repeatToPlay = NO;
	[self seekToTime:0 completionHandler:nil];
	
	if ([self.videoURL.scheme isEqualToString:@"file"]) {
		self.state = ZFPlayerStatePlaying;
	} else {
		self.state = ZFPlayerStateBuffering;
	}
}

/** 加载失败按钮事件 */
- (void)zf_controlView:(UIView *)controlView failAction:(UIButton *)sender {
	[self configZFPlayer];
}

- (void)zf_controlView:(UIView *)controlView resolutionAction:(UIButton *)sender {
	// 记录切换分辨率的时刻
	NSInteger currentTime = (NSInteger)CMTimeGetSeconds([self.player currentTime]);
	NSString *videoStr = self.videoURLArray[sender.tag - 200];
	NSURL *videoURL = [NSURL URLWithString:videoStr];
	if ([videoURL isEqual:self.videoURL]) { return; }
	self.isChangeResolution = YES;
	// reset player
	[self resetToPlayNewURL];
	self.videoURL = videoURL;
	// 从xx秒播放
	self.seekTime = currentTime;
	// 切换完分辨率自动播放
	[self autoPlayTheVideo];
}

- (void)zf_controlView:(UIView *)controlView downloadVideoAction:(UIButton *)sender {
	NSString *urlStr = self.videoURL.absoluteString;
	if ([self.delegate respondsToSelector:@selector(zf_playerDownload:)]) {
		[self.delegate zf_playerDownload:urlStr];
	}
}

- (void)zf_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value {
	// 视频总时间长度
	CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
	//计算出拖动的当前秒数
	NSInteger dragedSeconds = floorf(total * value);
	
	[self.controlView zf_playerPlayBtnState:YES];
	[self seekToTime:dragedSeconds completionHandler:^(BOOL finished) {}];
	
}

- (void)zf_controlView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider {
	// 拖动改变视频播放进度
	if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
		self.isDragged = YES;
		BOOL style = false;
		CGFloat value   = slider.value - self.sliderLastValue;
		if (value > 0) { style = YES; }
		if (value < 0) { style = NO; }
		if (value == 0) { return; }
		
		self.sliderLastValue  = slider.value;
		
		CGFloat totalTime     = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
		
		//计算出拖动的当前秒数
		CGFloat dragedSeconds = floorf(totalTime * slider.value);
		
		//转换成CMTime才能给player来控制播放进度
		CMTime dragedCMTime   = CMTimeMake(dragedSeconds, 1);
		
		[controlView zf_playerDraggedTime:dragedSeconds totalTime:totalTime isForward:style hasPreview:self.isFullScreen ? self.hasPreviewView : NO];
		
		if (totalTime > 0) { // 当总时长 > 0时候才能拖动slider
			if (self.isFullScreen && self.hasPreviewView) {
				
				[self.imageGenerator cancelAllCGImageGeneration];
				self.imageGenerator.appliesPreferredTrackTransform = YES;
				self.imageGenerator.maximumSize = CGSizeMake(100, 56);
				AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
					NSLog(@"%zd",result);
					if (result != AVAssetImageGeneratorSucceeded) {
						dispatch_async(dispatch_get_main_queue(), ^{
							[controlView zf_playerDraggedTime:dragedSeconds sliderImage:self.thumbImg ? : ZFPlayerImage(@"ZFPlayer_loading_bgView")];
						});
					} else {
						self.thumbImg = [UIImage imageWithCGImage:im];
						dispatch_async(dispatch_get_main_queue(), ^{
							[controlView zf_playerDraggedTime:dragedSeconds sliderImage:self.thumbImg ? : ZFPlayerImage(@"ZFPlayer_loading_bgView")];
						});
					}
				};
				[self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragedCMTime]] completionHandler:handler];
			}
		} else {
			// 此时设置slider值为0
			slider.value = 0;
		}
		
	}else { // player状态加载失败
		// 此时设置slider值为0
		slider.value = 0;
	}
	
}

- (void)zf_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider {
	if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
		self.isPauseByUser = NO;
		self.isDragged = NO;
		// 视频总时间长度
		CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
		//计算出拖动的当前秒数
		NSInteger dragedSeconds = floorf(total * slider.value);
		[self seekToTime:dragedSeconds completionHandler:nil];
	}
}

- (void)zf_controlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
	if ([self.delegate respondsToSelector:@selector(zf_playerControlViewWillShow:isFullscreen:)]) {
		[self.delegate zf_playerControlViewWillShow:controlView isFullscreen:fullscreen];
	}
}

- (void)zf_controlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
	if ([self.delegate respondsToSelector:@selector(zf_playerControlViewWillHidden:isFullscreen:)]) {
		[self.delegate zf_playerControlViewWillHidden:controlView isFullscreen:fullscreen];
	}
}

- (void)zf_controlView:(UIView *)controlView clickSendBarrage:(UIButton *)btn {
	if (self.isFullScreen) {
		self.keyBoardView.hidden = NO;
		[self.keyBoardView keyboardUpforComment];
		[self pauseByUser:NO];
	}
}

#pragma clang diagnostic pop

@end

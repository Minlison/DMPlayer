//
//  ZFFullScreenViewController.m
//  DMPlayerTest
//
//  Created by MinLison on 2017/5/2.
//  Copyright © 2017年 . All rights reserved.
//

#import "ZFFullScreenViewController.h"
#import "DMPlayer.h"
#import "DMKeyboardView.h"

@interface ZFFullScreenViewController ()
@end

@implementation ZFFullScreenViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// 监测设备方向
//	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//						 selector:@selector(onDeviceOrientationChange)
//						     name:UIDeviceOrientationDidChangeNotification
//						   object:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[UIViewController attemptRotationToDeviceOrientation];
}
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
	[ZFPlayerShared endEditing:YES];
	[[ZFPlayerView sharedPlayerView] endEditing:YES];
}

- (BOOL)shouldAutorotate
{
	return YES;
}
//- (void)onDeviceOrientationChange {
//	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//	UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
//	if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown ) { return; }
//	
//	switch (interfaceOrientation) {
//		case UIInterfaceOrientationPortraitUpsideDown:{
//		}
//			break;
//		case UIInterfaceOrientationPortrait:{
//		}
//			break;
//		case UIInterfaceOrientationLandscapeLeft:{
//			[self toOrientation:UIInterfaceOrientationLandscapeLeft];
//			
//		}
//			break;
//		case UIInterfaceOrientationLandscapeRight:{
//			[self toOrientation:UIInterfaceOrientationLandscapeRight];
//		}
//			break;
//		default:
//			break;
//	}
//}
//- (CGAffineTransform)getTransformRotationAngle {
//	// 状态条的方向已经设置过,所以这个就是你想要旋转的方向
//	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//	// 根据要进行旋转的方向来计算旋转的角度
//	if (orientation == UIInterfaceOrientationPortrait) {
//		return CGAffineTransformMakeRotation(-M_PI_2);
//	} else if (orientation == UIInterfaceOrientationLandscapeLeft){
//		return CGAffineTransformMakeRotation(-M_PI);
//	} else if(orientation == UIInterfaceOrientationLandscapeRight){
//		return CGAffineTransformIdentity;
//	}
//	return CGAffineTransformIdentity;
//}
//
//- (void)toOrientation:(UIInterfaceOrientation)orientation {
//	
//	// 获取到当前状态条的方向
//	UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//	// 判断如果当前方向和要旋转的方向一致,那么不做任何操作
//	if (currentOrientation == orientation) { return; }
//	
//	// iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
//	// 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
//	[[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
//	// 获取旋转状态条需要的时间:
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:0.3];
//	// 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
//	// 给你的播放视频的view视图设置旋转
//	self.view.transform = CGAffineTransformIdentity;
//	self.view.transform = [self getTransformRotationAngle];
//	// 开始旋转
//	[UIView commitAnimations];
//}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)prefersStatusBarHidden
{
	return ZFPlayerShared.isStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
@end

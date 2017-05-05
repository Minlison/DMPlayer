//
//  DMPlayer.h
//  DMPlayer
//
//  Created by MinLison on 2017/4/28.
//  Copyright © 2017年 . All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for DMPlayer.
FOUNDATION_EXPORT double DMPlayerVersionNumber;

//! Project version string for DMPlayer.
FOUNDATION_EXPORT const unsigned char DMPlayerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DMPlayer/PublicHeader.h>
#if __has_include(<DMPlayer/DMPlayer.h>)
#import <DMPlayer/DMBarrageData.h>
#import <DMPlayer/ZFPlayerView.h>
#import <DMPlayer/ZFPlayerModel.h>
#import <DMPlayer/ZFPlayerControlView.h>
#import <DMPlayer/ZFBrightnessView.h>
#import <DMPlayer/UITabBarController+ZFPlayerRotation.h>
#import <DMPlayer/UIViewController+ZFPlayerRotation.h>
#import <DMPlayer/UINavigationController+ZFPlayerRotation.h>
#import <DMPlayer/UIImageView+ZFCache.h>
#import <DMPlayer/UIWindow+CurrentViewController.h>
#import <DMPlayer/ZFPlayerControlViewDelegate.h>
#import <DMPlayer/DMPlayerCommonHeader.h>
#else
#import "DMBarrageData.h"
#import "ZFPlayerView.h"
#import "ZFPlayerModel.h"
#import "ZFPlayerControlView.h"
#import "ZFBrightnessView.h"
#import "UITabBarController+ZFPlayerRotation.h"
#import "UIViewController+ZFPlayerRotation.h"
#import "UINavigationController+ZFPlayerRotation.h"
#import "UIImageView+ZFCache.h"
#import "UIWindow+CurrentViewController.h"
#import "ZFPlayerControlViewDelegate.h"
#import "DMPlayerCommonHeader.h"
#endif

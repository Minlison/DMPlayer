//
//  DMPlayerCommonHeader.h
//  DMPlayerTest
//
//  Created by MinLison on 2017/4/28.
//  Copyright © 2017年 . All rights reserved.
//

#ifndef DMPlayerCommonHeader_h
#define DMPlayerCommonHeader_h
#import <UIKit/UIKit.h>


#define  DMUIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define DMNULLString(string) ((string == nil) || ([string isKindOfClass:[NSNull class]]) || (![string isKindOfClass:[NSString class]])||[string isEqualToString:@""] || [string isEqualToString:@"<null>"] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]== 0 )


#define DMNULLStringDefault(string,default) (DMNULLString(string) ? default : string)

#define DMNULLObject(obj) (obj == nil || obj == [NSNull null] || ([obj isKindOfClass:[NSString class]] && DMNULLString((NSString *)obj)))
#define DMNULLObjectDefault(obj,defalut) (DMNULLObject((id)obj) ? defalut : obj)


#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
// 监听TableView的contentOffset
#define kZFPlayerViewContentOffset          @"contentOffset"
#define kZFPlayerViewFrame		    @"frame"
// player的单例
#define ZFPlayerShared                      [ZFBrightnessView sharedBrightnessView]
// 屏幕的宽
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
// 颜色值RGB
#define RGBA(r,g,b,a)                       [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
// 图片路径
#define ZFPlayerSrcName(file)               [@"ZFPlayer.bundle" stringByAppendingPathComponent:file]

#define ZFPlayerFrameworkSrcName(file)      [@"Frameworks/ZFPlayer.framework/ZFPlayer.bundle" stringByAppendingPathComponent:file]

#define ZFPlayerImage(img) 		    [UIImage imageNamed:img inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]

//#define ZFPlayerImage(file)                 [UIImage imageNamed:ZFPlayerSrcName(file)] ? :[UIImage imageNamed:ZFPlayerFrameworkSrcName(file)]

#define ZFPlayerOrientationIsLandscape      UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)

#define ZFPlayerOrientationIsPortrait       UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)

#endif /* DMPlayerCommonHeader_h */

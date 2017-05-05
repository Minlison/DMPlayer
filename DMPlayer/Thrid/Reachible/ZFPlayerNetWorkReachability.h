//
//  NetWorkReachability.h
//  SECC01
//
//  Created by Harvey on 16/6/29.
//  Copyright © 2016年 Haley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, ZFPlayerNetWorkStatus) {
	ZFPlayerNetWorkStatusNotReachable = 0,
	ZFPlayerNetWorkStatusUnknown = 1,
	ZFPlayerNetWorkStatusWWAN2G = 2,
	ZFPlayerNetWorkStatusWWAN3G = 3,
	ZFPlayerNetWorkStatusWWAN4G = 4,
	ZFPlayerNetWorkStatusWiFi = 9,
};

extern NSString *kNetWorkReachabilityChangedNotification;

@interface ZFPlayerNetWorkReachability : NSObject
@property (copy, nonatomic) void (^ReachBlock)(ZFPlayerNetWorkStatus status, ZFPlayerNetWorkReachability *reach);
/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

- (BOOL)startNotifier;
- (BOOL)startNotifier:(void (^)(ZFPlayerNetWorkStatus status, ZFPlayerNetWorkReachability *reach))block;
- (void)stopNotifier;

- (ZFPlayerNetWorkStatus)currentReachabilityStatus;

@end

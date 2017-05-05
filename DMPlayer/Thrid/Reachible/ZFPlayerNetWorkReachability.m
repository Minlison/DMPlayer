//
//  NetWorkReachability.m
//  SECC01
//
//  Created by Harvey on 16/6/29.
//  Copyright © 2016年 Haley. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>
#import <netinet/in.h>

#import "ZFPlayerNetWorkReachability.h"

NSString *kNetWorkReachabilityChangedNotification = @"kReachabilityChangedNotification";

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	ZFPlayerNetWorkReachability *networkObject = (__bridge ZFPlayerNetWorkReachability *)info;
	if (networkObject.ReachBlock)
	{
		networkObject.ReachBlock([networkObject currentReachabilityStatus],networkObject);
	}
	[[NSNotificationCenter defaultCenter] postNotificationName: kNetWorkReachabilityChangedNotification object:networkObject];
}

@implementation ZFPlayerNetWorkReachability
{
	SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
	ZFPlayerNetWorkReachability *returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability != NULL) {
		returnValue = [[self alloc] init];
		if (returnValue != NULL) {
			returnValue->_reachabilityRef = reachability;
		} else {
			CFRelease(reachability);
		}
	}
	return returnValue;
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
	
	ZFPlayerNetWorkReachability* returnValue = NULL;
	
	if (reachability != NULL)
	{
		returnValue = [[self alloc] init];
		if (returnValue != NULL)
		{
			returnValue->_reachabilityRef = reachability;
		}
		else {
			CFRelease(reachability);
		}
	}
	return returnValue;
}

+ (instancetype)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

- (BOOL)startNotifier
{
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	
	if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
			returnValue = YES;
		}
	}
	return returnValue;
}
- (BOOL)startNotifier:(void (^)(ZFPlayerNetWorkStatus status, ZFPlayerNetWorkReachability *reach))block
{
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	
	if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
			returnValue = YES;
		}
	}
	self.ReachBlock = block;
	return returnValue;
}
- (ZFPlayerNetWorkStatus)currentReachabilityStatus
{
	ZFPlayerNetWorkStatus returnValue = ZFPlayerNetWorkStatusNotReachable;
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
	{
		returnValue = [self networkStatusForFlags:flags];
	}
	
	return returnValue;
}

- (ZFPlayerNetWorkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// The target host is not reachable.
		return ZFPlayerNetWorkStatusNotReachable;
	}
	
	ZFPlayerNetWorkStatus returnValue = ZFPlayerNetWorkStatusNotReachable;
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		/*
		 If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
		 */
		returnValue = ZFPlayerNetWorkStatusWiFi;
	}
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
	     (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
		/*
		 ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
		 */
		
		if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
		{
			/*
			 ... and no [user] intervention is needed...
			 */
			returnValue = ZFPlayerNetWorkStatusWiFi;
		}
	}
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		/*
		 ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
		 */
		NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
					   CTRadioAccessTechnologyGPRS,
					   CTRadioAccessTechnologyCDMA1x];
		
		NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
					   CTRadioAccessTechnologyWCDMA,
					   CTRadioAccessTechnologyHSUPA,
					   CTRadioAccessTechnologyCDMAEVDORev0,
					   CTRadioAccessTechnologyCDMAEVDORevA,
					   CTRadioAccessTechnologyCDMAEVDORevB,
					   CTRadioAccessTechnologyeHRPD];
		
		NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
		
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
			CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
			NSString *accessString = teleInfo.currentRadioAccessTechnology;
			if ([typeStrings4G containsObject:accessString]) {
				return ZFPlayerNetWorkStatusWWAN4G;
			} else if ([typeStrings3G containsObject:accessString]) {
				return ZFPlayerNetWorkStatusWWAN3G;
			} else if ([typeStrings2G containsObject:accessString]) {
				return ZFPlayerNetWorkStatusWWAN2G;
			} else {
				return ZFPlayerNetWorkStatusUnknown;
			}
		} else {
			return ZFPlayerNetWorkStatusUnknown;
		}
	}
	
	return returnValue;
}

- (void)stopNotifier
{
	if (_reachabilityRef != NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}

- (void)dealloc
{
	[self stopNotifier];
	if (_reachabilityRef != NULL)
	{
		CFRelease(_reachabilityRef);
	}
}


@end

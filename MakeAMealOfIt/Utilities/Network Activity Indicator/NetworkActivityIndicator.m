//
//  NetworkActivityIndicator.m
//  ShutterBug
//
//  Created by James Valaitis on 07/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "NetworkActivityIndicator.h"

#pragma mark - Definition

#define networkActivityIndicator		[UIApplication sharedApplication].networkActivityIndicatorVisible

#pragma mark - Network Activity Indicator Implementation

@implementation NetworkActivityIndicator {}

#pragma mark - Maintenance Methods

/**
 *	changes how many people are using the network activity indicator
 *
 *	@param	
 */
+ (void)changeCounterBy:(NSUInteger)counterDelta
{
	static NSUInteger count				= 0;
	static dispatch_queue_t queue;
	
	if (!queue)
		queue							= dispatch_queue_create("NetworkActivityIndicator Queue", nil);
	
	dispatch_sync(queue,
	^{
		if (count + counterDelta <= 0)
		{
			count						= 0;
			networkActivityIndicator	= NO;
		}
		else
		{
			count						+= counterDelta;
			networkActivityIndicator	= YES;
		}
	});
}

#pragma mark - Network Activity Indicator Methods

/**
 *	starts the activity indicator
 */
+ (void)start
{
	[self changeCounterBy:1];
}

/**
 *	stops the activity indicator
 */
+ (void)stop
{
	[self changeCounterBy:-1];
}

@end
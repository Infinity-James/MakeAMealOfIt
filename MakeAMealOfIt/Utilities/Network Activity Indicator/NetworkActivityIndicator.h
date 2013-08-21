//
//  NetworkActivityIndicator.h
//  ShutterBug
//
//  Created by James Valaitis on 07/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Network Activity Indicator Public Interface

@interface NetworkActivityIndicator : NSObject {}

#pragma mark - Public Methods

/**
 *	Forces the stopping of the activity indicator, no matter who is waiting for it.
 */
+ (void)forceStop;
/**
 *	Starts the activity indicator.
 */
+ (void)start;
/**
 *	Stops the activity indicator.
 */
+ (void)stop;

@end
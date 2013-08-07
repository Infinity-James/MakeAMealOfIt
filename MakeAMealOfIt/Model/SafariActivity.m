//
//  SafariActivity.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 07/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "SafariActivity.h"

#pragma mark - Safari Activity Private Class Extension

@interface SafariActivity () {}

#pragma mark - Private Properties

/**	*/
@property (nonatomic, copy)	NSURL	*url;

@end

#pragma mark - Safari Activity Implementation

@implementation SafariActivity {}

#pragma mark - UIActivity Methods

/**
 *	An image that identifies the service to the user.
 *
 *	@return	An image that can be presented to the user.
 */
- (UIImage *)activityImage
{
	return [UIImage imageNamed:@"activity_safari_yummly"];
}

/**
 *	A user-readable string describing the service.
 *
 *	@return	A string that describes the service.
 */
- (NSString *)activityTitle
{
	return @"Safari";
}

/**
 *	An identifier for the type of service being provided.
 *
 *	@return	A string that identifies the provided service to your app.
 */
- (NSString *)activityType
{
	return [[NSString alloc] initWithFormat:@"co.andbeyond.makeamealofit.%@", NSStringFromClass([self class])];
}

/**
 *	Returns a Boolean indicating whether the service can act on the specified data items.
 *
 *	@param	activityItems				An array of objects of varying types. These are the data objects on which the service would act.
 *
 *	@return	YES if your service can act on the specified data items or NO if it cannot.
 */
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems)
		if ([activityItem isKindOfClass:[NSURL class]])
			if ([[UIApplication sharedApplication] canOpenURL:activityItem])
				return YES;
	
	return NO;
}

/**
 *	Prepares your service to act on the specified data.
 *
 *	@param	activityItems				An array of objects of varying types. These are the data objects on which to act.
 */
- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems)
		if ([activityItem isKindOfClass:[NSURL class]])
			self.url					= activityItem;
}

/**
 *	Performs the service when no custom view controller is provided.
 */
- (void)performActivity
{
	BOOL completed						= [[UIApplication sharedApplication] openURL:self.url];
	
	[self activityDidFinish:completed];
}

@end
//
//  UIRightViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 10/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UIRightViewController.h"

#pragma mark - Right View Controller Private Class Extension

@interface UIRightViewController () {}

@end

#pragma mark - Right View Controller Implementation

@implementation UIRightViewController {}

#pragma mark - Autorotation

/**
 *	Returns a Boolean value indicating whether rotation methods are forwarded to child view controllers.
 *
 *	@param	YES if rotation methods are forwarded or NO if they are not.
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	Returns whether the view controller’s contents should auto rotate.
 *
 *	@param	YES if the content should rotate, otherwise NO.
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

/**
 *	Sent to the view controller just before the user interface begins rotating.
 *
 *	@param	toInterfaceOrientation		The new orientation for the user interface. The possible values are described in UIInterfaceOrientation.
 *	@param	duration					The duration of the pending rotation, measured in seconds.
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Setter & Getter Methods

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{};
}

#pragma mark - View Lifecycle

/**
 *	Sent to the view controller when the app receives a memory warning.
 */
- (void)didReceiveMemoryWarning
{
	if (!self.view.window)
	{
		
	}
	
	[super didReceiveMemoryWarning];
}

/**
 *	Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor			= [UIColor whiteColor];
}

/**
 *	Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 *	@param	animated					If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
}

@end
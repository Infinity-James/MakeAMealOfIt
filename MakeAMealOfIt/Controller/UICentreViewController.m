//
//  UICentreViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UICentreViewController.h"

#pragma mark - Centre View Controller Private Class Extension

@interface UICentreViewController () {}

@end

#pragma mark - Centre View Controller Implementation

@implementation UICentreViewController {}

#pragma mark - Initialisation
	
/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animate						Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animate
{
}

#pragma mark - Setter & Getter Methods

/**
 *	A toolbar to keep at the top of the view.
 *
 *	@return	A fully initialised toolbar to be used at the top of centre views.
 */
- (UIToolbar *)toolbar
{
	//	use lazy instantiation to create and design toolbar at the last minute
	if (!_toolbar)
	{
		_toolbar						= [[UIToolbar alloc] init];
		_toolbar.clipsToBounds			= NO;
		_toolbar.translatesAutoresizingMaskIntoConstraints		= NO;
		_toolbar.translucent			= YES;
		[self.view addSubview:_toolbar];
		[self.view bringSubviewToFront:_toolbar];
	}
	
	return _toolbar;
}

/**
 *	Returns the correct height for a toolbar, depending on the orientation.
 *
 *	@return	A smaller height for landscape and taller for portrait.
 */
- (CGFloat)toolbarHeight
{	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		return 32.0f;
	
	return 44.0f;
}

#pragma mark - View Lifecycle

/**
 *	Sent to the view controller when the app receives a memory warning.
 */
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

/**
 *	Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor	= [UIColor whiteColor];
	[self addToolbarItemsAnimated:NO];
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

/**
 *	Notifies the view controller that its view is about to layout its subviews.
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
}

@end
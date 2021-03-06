//
//  UICentreViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "UICentreViewController.h"

#pragma mark - Centre View Controller Private Class Extension

@interface UICentreViewController () {}

@end

#pragma mark - Centre View Controller Implementation

@implementation UICentreViewController {}

#pragma mark - Action & Selector Methods

/**
 *	Called when the Slide Navigation Controller's state has been updated.
 *
 *	@param	notification				NSNotification objects encapsulate information so that it can be broadcast to other objects.
 */
- (void)slideNavigationStateEventOccured:(NSNotification *)notification
{
	if (!self.slideNavigationController || !self.currentlyCentre)
		return;
	
	NSDictionary *userInfo				= notification.userInfo;
	SlideNavigationStateEvent event		= [(NSNumber *)userInfo[SlideNavigationStateEventTypeKey] integerValue];
	
	switch (event)
	{
		case SlideNavigationStateEventDidClose:		[self slideNavigationControllerDidClose];	break;
		case SlideNavigationStateEventDidOpen:		[self slideNavigationControllerDidOpen];	break;
		case SlideNavigationStateEventWillClose:	[self slideNavigationControllerWillClose];	break;
		case SlideNavigationStateEventWillOpen:		[self slideNavigationControllerWillOpen];	break;
	}
}

#pragma mark - Autolayout Methods

/**
 *	Called when the view controller’s view needs to update its constraints.
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	[self.view bringSubviewToFront:self.slideNavigationController.slideNavigationBar];
}

#pragma mark - Initialisation
	
/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animated					Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animated
{
}

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(slideNavigationStateEventOccured:)
													 name:SlideNavigationStateEventNotification
												   object:nil];
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	Keeps track of whether there is an internet connection or not.
 *
 *	@return	YES if the internet connection exists, or NO.
 */
- (BOOL)internetConnectionExists
{
	return appDelegate.internetConnectionExists;
}

/**
 *	The slide navigation item used to represent the view controller in a parent’s toolbar.
 *
 *	@return	An initialised SlideNavigationItem.
 */
- (SlideNavigationItem *)slideNavigationItem
{
	if (!_slideNavigationItem)
		_slideNavigationItem			= [[SlideNavigationItem alloc] init];
	
	return _slideNavigationItem;
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets whether this centre view controller is the current centre view controller for the slideNavigationController.
 *
 *	@param	currentlyCentre				YES if this is currently the centreViewController, NO if it is not being displayed or is to the left.
 */
- (void)setCurrentlyCentre:(BOOL)currentlyCentre
{
	if (_currentlyCentre == currentlyCentre)
		return;
	_currentlyCentre					= currentlyCentre;
	
	if (_currentlyCentre)
		[self centreViewControllerMadeCentre];
}

/**
 *	The setter for the slideNavigationController of this UICentreViewController.
 *
 *	@param	slideNavigationController	The nearest ancestor in the view controller hierarchy that's a slide navigation controller.
 */
- (void)setSlideNavigationController:(SlideNavigationController *)slideNavigationController
{
	_slideNavigationController			= slideNavigationController;
	
	[self.slideNavigationItem setDelegate:_slideNavigationController];
}

#pragma mark - Slide Navigation Controller Lifecycle

/**
 *	Called when this view controller has been made the main centreViewController of the slideNavigationController.
 */
- (void)centreViewControllerMadeCentre
{
	
}

/**
 *	Notifies the view controller that the parent slideNavigationController has closed all side views.
 */
- (void)slideNavigationControllerDidClose
{
	
}

/**
 *	Notifies the view controller that the parent slideNavigationController has open a side view.
 */
- (void)slideNavigationControllerDidOpen
{
	
}

/**
 *	Notifies the view controller that the parent slideNavigationController will close all side views.
 */
- (void)slideNavigationControllerWillClose
{
	
}

/**
 *	Notifies the view controller that the parent slideNavigationController will open a side view.
 */
- (void)slideNavigationControllerWillOpen
{
	
}

#pragma mark - View Lifecycle

/**
 *	Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 *	@param	animated					If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
	self.view.backgroundColor			= [UIColor whiteColor];
	[self addToolbarItemsAnimated:NO];
}

@end
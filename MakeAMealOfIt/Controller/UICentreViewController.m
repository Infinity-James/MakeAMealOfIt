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

#pragma mark - Action & Selector Methods

/**
 *	Called when the Slide Navigation Controller's state has been updated.
 *
 *	@param	notification				NSNotification objects encapsulate information so that it can be broadcast to other objects.
 */
- (void)slideNavigationStateEventOccured:(NSNotification *)notification
{
	NSDictionary *userInfo				= notification.userInfo;
	SlideNavigationStateEvent event		= [(NSNumber *)userInfo[SlideNavigationStateEventTypeKey] integerValue];
	[self slideNavigationControllerStateUpdated:event];
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
 *	@param	animate						Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animate
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
 *
 *
 *	@return
 */
- (SlideNavigationItem *)slideNavigationItem
{
	if (!_slideNavigationItem)
		_slideNavigationItem			= [[SlideNavigationItem alloc] init];
	
	return _slideNavigationItem;
}

#pragma mark - Property Accessor Methods - Setters

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
 *	Called when the Slide Navigation Controller's state has been updated.
 *
 *	@param	stateEvent					The new state of the Slide Navigation Controller.
 */
- (void)slideNavigationControllerStateUpdated:(SlideNavigationStateEvent)stateEvent
{
	
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
	self.view.backgroundColor			= [UIColor whiteColor];
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

@end
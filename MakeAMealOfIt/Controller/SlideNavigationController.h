//
//  MainViewController.h
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "SlideNavigationBar.h"
#import "SlideNavigationItemDelegate.h"

@class UICentreViewController;

#pragma mark - Type Definitions

typedef NS_ENUM(NSUInteger, SideControllerState)
{
	SlideNavigationSideControllerClosed,			//	no side controller is visible
	SlideNavigationSideControllerLeftOpen,			//	left view is visible
	SlideNavigationSideControllerRightOpen			//	right view is visible
};

#pragma mark - Main View Controller Public Interface

@interface SlideNavigationController : UIViewController <SlideNavigationItemDelegate> {}

#pragma mark - Public Properties - View Controller

/**	The view controller to have to the left	*/
@property (nonatomic, strong)	UIViewController	*leftViewController;
/**	The view controller to have to the right	*/
@property (nonatomic, strong)	UIViewController	*rightViewController;
/**	*/
@property (nonatomic, strong)	SlideNavigationBar	*slideNavigationBar;

#pragma mark - Public Properties - State

/**	The current state of if a side view is visible or not.	*/
@property (nonatomic, readonly, assign)	SideControllerState		controllerState;
/**	Whether there should be shadows on the view controllers.	*/
@property (nonatomic, assign)			BOOL					shadowEnabled;
/**	Whether to simultaneously slide the side views along with the centre view or not.	*/
@property (nonatomic, assign)			BOOL					simultaneouslySlideSideViews;

#pragma mark - Public Methods - Initialisation

/**
 *	Called to initialise a class instance with a centre view controller to adopt.
 *
 *	@param	centreViewController		The view controller to present in the centre.
 */
- (instancetype)initWithCentreViewController:(UICentreViewController *)centreViewController;
/**
 *	Called to initialise a class instance with a centre view controller to adopt.
 *
 *	@param	centreViewController		The view controller to present in the centre.
 *	@param	leftViewController			The left view controller to set.
 *	@param	rightViewController			The right view controller to set.
 */
- (instancetype)initWithCentreViewController:(UICentreViewController *)centreViewController
						  leftViewController:(UIViewController *)leftViewController
					  andRightViewController:(UIViewController *)rightViewController;

#pragma mark - Public Methods - Navigation

/**
 *	Pops the top centre view controller, along with it's left and right counter parts (not visible), from the navigation stack and updates the display.
 *
 *	@param	animated					Set this value to YES to animate the transition, No otherwise.
 */
- (void)popCentreViewControllerAnimated:(BOOL)animated;

/**
 *	Pushes a new centre view controller with an accompanying right view controller.
 *
 *	@param	pushedCentreViewController	The view controller to be set as the new centre view controller.
 *	@param	rightViewController			The new right view controller to be paired with the new centre view controller.
 */
- (void)pushCentreViewController:(UICentreViewController *)pushedCentreViewController withRightViewController:(UIViewController *)rightViewController animated:(BOOL)animated;

#pragma mark - Public Methods - State 

/**
 *	Set the state of this slide controller, closed, left open or right open.
 *
 *	@param	controllerState				The desired SideControllerState.
 *	@param	completionHandler			The completion handler to be called once the controllerState was set.
 */
- (void) setControllerState:(SideControllerState)controllerState
	  withCompletionHandler:(void(^)())completionHandler;

@end
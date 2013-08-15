//
//  UICentreViewController.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 30/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "SlideNavigationItem.h"

#pragma mark - Centre View Controller Public Interface

@interface UICentreViewController : UIViewController {}

#pragma mark - Public Properties

/**	A bool indicating whether this centre view has been slid at least once.	*/
@property (nonatomic, assign)	BOOL						hasBeenSlid;
/**	The nearest ancestor in the view controller hierarchy that's a slide navigation controller.	*/
@property (nonatomic, weak)		SlideNavigationController	*slideNavigationController;
/** The slide navigation item used to represent the view controller in a parent’s toolbar.	*/
@property (nonatomic, strong)	SlideNavigationItem			*slideNavigationItem;

#pragma mark - Public Methods

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animated					Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animated;
/**
 *	Notifies the view controller that the parent slideNavigationController has closed all side views.
 */
- (void)slideNavigationControllerDidClose;
/**
 *	Notifies the view controller that the parent slideNavigationController has open a side view.
 */
- (void)slideNavigationControllerDidOpen;
/**
 *	Notifies the view controller that the parent slideNavigationController will close all side views.
 */
- (void)slideNavigationControllerWillClose;
/**
 *	Notifies the view controller that the parent slideNavigationController will open a side view.
 */
- (void)slideNavigationControllerWillOpen;

@end
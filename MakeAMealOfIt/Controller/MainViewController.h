//
//  MainViewController.h
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "CentreViewControllerProtocol.h"

#pragma mark - Main View Controller Public Interface

@interface MainViewController : UIViewController {}

#pragma mark - Public Properties

/**	The view controller to have to the left	*/
@property (nonatomic, strong)	UIViewController	*leftViewControllerClass;
/**	The view controller to have to the right	*/
@property (nonatomic, strong)	UIViewController	*rightViewControllerClass;

#pragma mark - Public Methods

/**
 *	Called to initialise a class instance with a centre view controller to adopt.
 *
 *	@param	centreViewController		The view controller to present in the centre.
 */
- (instancetype)initWithCentreViewController:(UIViewController <CentreViewControllerProtocol> *)centreViewController;
/**
 *	Handles the transitioning to a new centre view controller.
 *
 *	@param	viewController				The view controller to be set as the new centre view controller.
 */
- (void)transitionCentreToViewController:(UIViewController *)viewController;

@end
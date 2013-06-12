//
//  SlideOutNavigationController.h
//  Navigation
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "MainViewController.h"

#pragma mark - Slide Out Navigation Controller Public Interface

@interface SlideOutNavigationController : NSObject

#pragma mark - Public Properties

@property (nonatomic, strong)	MainViewController		*mainViewController;

#pragma mark - Public Methods

/**
 *	presents a new centre view controller
 *
 *	@param	centreViewController		new centre view controller
 *	@param	rightViewController			new right slide out view controller
 */
- (void)showCentreViewController:(UIViewController *)centreViewController
		 withRightViewController:(UIViewController *)rightViewController;

@end
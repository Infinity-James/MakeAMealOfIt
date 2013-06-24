//
//  SlideOutNavigationController.m
//  Navigation
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "CupboardViewController.h"
#import "ExtraOptionsViewController.h"
#import "RecipeSearchViewController.h"
#import "RecipesViewController.h"
#import "SlideOutNavigationController.h"

#pragma mark - Slide Out Navigation Controller Implementation

@implementation SlideOutNavigationController

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 */
- (instancetype)init
{
	if (self = [super init])
	{
		//RecipesViewController *recipes	= [[RecipesViewController alloc] init];
		RecipeSearchViewController *recipeSearch			= [[RecipeSearchViewController alloc] init];
		self.mainViewController								= [[MainViewController alloc] initWithCentreViewController:recipeSearch];
		self.mainViewController.leftViewControllerClass		= [[CupboardViewController alloc] init];
		self.mainViewController.rightViewControllerClass	= [[ExtraOptionsViewController alloc] init];
	}
	
	return self;
}

#pragma mark - View Controller Methods

/**
 *	presents a new centre view controller
 *
 *	@param	centreViewController		new centre view controller
 *	@param	rightViewController			new right slide out view controller
 */
- (void)showCentreViewController:(UIViewController *)centreViewController
		 withRightViewController:(UIViewController *)rightViewController
{
	[self.mainViewController transitionCentreToViewController:centreViewController withNewRightViewController:rightViewController];
}

@end
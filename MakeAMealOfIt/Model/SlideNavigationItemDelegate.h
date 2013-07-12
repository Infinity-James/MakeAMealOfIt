//
//  SlideNavigationItemDelegate.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 09/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Slide Navigation Item Delegate

@class SlideNavigationItem;

#pragma mark - Type Definitions

typedef void(^PresentBackButton)(UIBarButtonItem *backButton);

@protocol SlideNavigationItemDelegate <NSObject>

#pragma mark - Required Methods

@required

/**
 *	The slide navigation item is asking if it needs a back button,
 *
 *	@param	slideNavigationItem			The slide navigation item calling this method.
 *
 *	@return	An initialised bar button item or nil if it is not needed.
 */
- (UIBarButtonItem *)backButtonRequestedBySlideNavigationItem:(SlideNavigationItem *)slideNavigationItem;

/**
 *	The bar button items of a slide navigation bar at a certain position have been set.
 *
 *	@param	slideNavigationItem			The slide navigation item calling this method.
 *	@param	items						The items to update a slide navigation bar with.
 *	@param	animated					Specify YES to animate the setting of the SlideNavigationBar, NO otherwise.
 */
- (void)slideNavigationItem:(SlideNavigationItem *)slideNavigationItem
				   setItems:(NSArray *)items
				   animated:(BOOL)animated;

@end
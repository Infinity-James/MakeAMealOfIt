//
//  SlideNavigationItem.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 09/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "SlideNavigationItemDelegate.h"

#pragma mark - Slide Navigation Item Public Interface

@interface SlideNavigationItem : NSObject {}

#pragma mark - Public Properties
/**	A bar button item displayed on the left of the slide navigation bar when the receiver is the top slide navigation item.	*/
@property (nonatomic, strong)	UIBarButtonItem	*leftBarButtonItem;
/**	An array of bar button items to display on the left side of the slide navigation bar when the receiver is the top slide navigation item.	*/
@property (nonatomic, copy)		NSArray			*leftBarButtonItems;
/**	A bar button item displayed on the right of the slide navigation bar when the receiver is the top slide navigation item.	*/
@property (nonatomic, strong)	UIBarButtonItem	*rightBarButtonItem;
/**	An array of bar button items to display on the right side of the slide navigation bar when the receiver is the top slide navigation item.	*/
@property (nonatomic, copy)		NSArray			*rightBarButtonItems;
/**	The slide navigation item’s title displayed in the center of the slide navigation bar.	*/
@property (nonatomic, copy)		NSString		*title;

#pragma mark - Public Methods

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	delegate					The item interested in what changes in this slide navigation item.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithDelegate:(id <SlideNavigationItemDelegate>)delegate;
/**
 *	Nilify the current delegate for this slide navigation item
 */
- (void)removeDelegate;
/**
 *	Sets the delegate for this slide navigation item.
 *
 *	@param	The item interested in what changes in this slide navigation item.
 */
- (void)setDelegate:(id<SlideNavigationItemDelegate>)delegate;
/**
 *	Sets the left bar button item, optionally animating the transition to the new item.
 *
 *	@param	leftBarButtonItem			A custom bar item to display on the left side of the navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar item when this item is the top item, NO otherwise.
 */
- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
					animated:(BOOL)animated;
/**
 *	Sets the left bar button items, optionally animating the transition to the new items.
 *
 *	@param	leftBarButtonItems			An array of custom bar button items to display on the left side of the slide navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar items when this item is the top item, NO otherwise.
 */
- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
					 animated:(BOOL)animated;
/**
 *	Sets the custom bar button item, optionally animating the transition to the view.
 *
 *	@param	rightBarButtonItem			A custom bar item to display on the right of the navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar item when this item is the top item, NO otherwise.
 */
- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
					 animated:(BOOL)animated;
/**
 *	Sets the right bar button items, optionally animating the transition to the new items.
 *
 *	@param	rightBarButtonItems			An array of custom bar button items to display on the right side of the slide navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar items when this item is the top item, NO otherwise.
 */
- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
					  animated:(BOOL)animated;

/**
 *	Set the slide navigation item’s title displayed in the center of the slide navigation bar.
 *
 *	@param	title						The slide navigation item’s title.
 *	@param	animated					Specify YES to animate the transition to the custom bar items when this item is the top item, NO otherwise.
 */
- (void)setTitle:(NSString *)title
		animated:(BOOL)animated;

@end
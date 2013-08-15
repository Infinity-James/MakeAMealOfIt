//
//  SlideNavigationItem.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 09/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "SlideNavigationItem.h"

#pragma mark - Slide Navigation Item Private Class Extension

@interface SlideNavigationItem () {}

#pragma mark - Private Properties

/**	*/
@property (nonatomic, strong)	UIBarButtonItem					*backButton;
/**	The item interested in what changes in this slide navigation item.	*/
@property (nonatomic, weak)	id <SlideNavigationItemDelegate>	delegate;
/**	Used to separate the items in an elegant way.	*/
@property (nonatomic, strong)	UIBarButtonItem					*flexibleSpace;

@end

#pragma mark - Slide Navigation Item Private Class Extension

@implementation SlideNavigationItem {}

#pragma mark - Synthesise Properties

@synthesize leftBarButtonItems			= _leftBarButtonItems;
@synthesize rightBarButtonItems			= _rightBarButtonItems;

#pragma mark - Delegate Management

/**
 *	Nilify the current delegate for this slide navigation item
 */
- (void)removeDelegate
{
	self.delegate						= nil;
}

/**
 *	Updates the delegates ith the currently set bar button items.
 *
 *	@param	animated					Whether the delegate should update in an animated fashion with the items we give it.
 */
- (void)updateDelegateAnimated:(BOOL)animated
{
	[self.delegate slideNavigationItem:self setItems:self.items animated:animated];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	delegate					The item interested in what changes in this slide navigation item.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithDelegate:(id <SlideNavigationItemDelegate>)delegate
{
	if (self = [super init])
	{
		self.delegate					= delegate;
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	Used to separate the items in an elegant way.
 *
 *	@return	An initialised bar button item to be used for flexible spacing.
 */
- (UIBarButtonItem *)flexibleSpace
{
	if (!_flexibleSpace)
		_flexibleSpace					= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	
	return _flexibleSpace;
}

/**
 *	Updates the items to be displayed in a SlideNavigationController.
 *
 *	@return	An array of bar button items.
 */
- (NSArray *)items
{
	NSMutableArray *items				= [[NSMutableArray alloc] init];
	
	if (self.backButton)
		[items addObject:self.backButton];
	
	if (self.leftBarButtonItems)
		[items addObjectsFromArray:self.leftBarButtonItems];
	
	[items addObject:self.flexibleSpace];
	
	if (self.title)
	{
		//	this label will be used as the title in the toolbar
		UILabel *title					= [[UILabel alloc] init];
		title.backgroundColor			= [UIColor clearColor];
		
		//	we use the title and calculate the maximum number of character able to be displayed in the title
		NSUInteger maximumCharacters	= ([UIScreen mainScreen].bounds.size.width / 10.0f) - 10.0f;
		
		//	limit the title using the calculated number of character
		if (self.title.length > maximumCharacters)
		{
			NSRange removalRange		= NSMakeRange(maximumCharacters, self.title.length - maximumCharacters);
			self.title					= [self.title stringByReplacingCharactersInRange:removalRange withString:@""];
		}
		//	use the title in the label, customise it, and then make a bar button item with it
		title.font						= kYummlyBolderFontWithSize(FontSizeForTextStyle(UIFontTextStyleHeadline));
		title.text						= self.title;
		title.textAlignment				= NSTextAlignmentCenter;
		title.textColor					= kYummlyColourMain;
		
		[title sizeToFit];
		UIBarButtonItem *titleItem		= [[UIBarButtonItem alloc] initWithCustomView:title];
		
		[items addObject:titleItem];
	}
	
	[items addObject:self.flexibleSpace];
	
	if (self.rightBarButtonItems)
		[items addObjectsFromArray:self.rightBarButtonItems];
	
	//	store the updated items
	return items;
}

/**
 *	A bar button item displayed on the left of the slide navigation bar when the receiver is the top slide navigation item.
 *
 *	@return A UIBarButtonItem is there is one set on the left side, nil otherwise.
 */
- (UIBarButtonItem *)leftBarButtonItem
{
	return self.leftBarButtonItems[0];
}

/**
 *	An array of custom bar button items to display on the left side of the slide navigation bar.
 *
 *	@return	An array of custom bar button items to display on the left side of the slide navigation bar.
 */
- (NSArray *)leftBarButtonItems
{
	if (!_leftBarButtonItems)
		_leftBarButtonItems				= @[];
	
	return _leftBarButtonItems;
}

/**
 *	A bar button item displayed on the right of the slide navigation bar when the receiver is the top slide navigation item.
 *
 *	@return A UIBarButtonItem is there is one set on the right side, nil otherwise.
 */
- (UIBarButtonItem *)rightBarButtonItem
{
	return self.rightBarButtonItems[0];
}

/**
 *	An array of custom bar button items to display on the right side of the slide navigation bar.
 *
 *	@return	An array of custom bar button items to display on the right side of the slide navigation bar.
 */
- (NSArray *)rightBarButtonItems
{
	if (!_rightBarButtonItems)
		_rightBarButtonItems			= @[];
	
	return _rightBarButtonItems;
}

/**
 *	Sets the delegate for this slide navigation item.
 *
 *	@param	The item interested in what changes in this slide navigation item.
 */
- (void)setDelegate:(id<SlideNavigationItemDelegate>)delegate
{
	_delegate							= delegate;
	
	//	if there is a delegate we update it with all of the current properties of this item
	if (_delegate)
	{
		self.backButton					= [self.delegate backButtonRequestedBySlideNavigationItem:self];
		[self updateDelegateAnimated:YES];
	}
}

/**
 *	Sets the left bar button item, optionally animating the transition to the new item.
 *
 *	@param	leftBarButtonItem			A custom bar item to display on the left side of the navigation bar.
 */
- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
	[self setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

/**
 *	Sets the left bar button item, optionally animating the transition to the new item.
 *
 *	@param	leftBarButtonItem			A custom bar item to display on the left side of the navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar item when this item is the top item, NO otherwise.
 */
- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
					animated:(BOOL)animated
{
	NSMutableArray *leftItems			= [self.leftBarButtonItems mutableCopy];
	
	if (leftItems.count > 0)
		leftItems[0]						= leftBarButtonItem;
	else
		[leftItems insertObject:leftBarButtonItem atIndex:0];
	
	[self setLeftBarButtonItems:leftItems animated:animated];
}

/**
 *	Sets the left bar button items, optionally animating the transition to the new items.
 *
 *	@param	leftBarButtonItems			An array of custom bar button items to display on the left side of the slide navigation bar.
 */
- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
{
	[self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

/**
 *	Sets the left bar button items, optionally animating the transition to the new items.
 *
 *	@param	leftBarButtonItems			An array of custom bar button items to display on the left side of the slide navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar items when this item is the top item, NO otherwise.
 */
- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
					 animated:(BOOL)animated
{
	_leftBarButtonItems					= leftBarButtonItems;
	[self updateDelegateAnimated:animated];
}

/**
 *	Sets the custom bar button item, optionally animating the transition to the view.
 *
 *	@param	rightBarButtonItem			A custom bar item to display on the right of the navigation bar.
 */
- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
	[self setRightBarButtonItem:rightBarButtonItem animated:NO];
}

/**
 *	Sets the custom bar button item, optionally animating the transition to the view.
 *
 *	@param	rightBarButtonItem			A custom bar item to display on the right of the navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar item when this item is the top item, NO otherwise.
 */
- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
					 animated:(BOOL)animated
{
	NSMutableArray *rightItems			= [self.rightBarButtonItems mutableCopy];
	
	if (rightItems.count > 0)
		rightItems[0]						= rightBarButtonItem;
	else
		[rightItems insertObject:rightBarButtonItem atIndex:0];
	
	[self setRightBarButtonItems:rightItems animated:animated];
}

/**
 *	Sets the right bar button items, optionally animating the transition to the new items.
 *
 *	@param	rightBarButtonItems			An array of custom bar button items to display on the right side of the slide navigation bar.
 */
- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
{
	[self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

/**
 *	Sets the right bar button items, optionally animating the transition to the new items.
 *
 *	@param	rightBarButtonItems			An array of custom bar button items to display on the right side of the slide navigation bar.
 *	@param	animated					Specify YES to animate the transition to the custom bar items when this item is the top item, NO otherwise.
 */
- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
					  animated:(BOOL)animated
{
	_rightBarButtonItems				= rightBarButtonItems;
	[self updateDelegateAnimated:animated];
}

/**
 *	Set the slide navigation item’s title displayed in the center of the slide navigation bar.
 *
 *	@param	title						The slide navigation item’s title.
 *	@param	animated					Specify YES to animate the transition to the custom bar items when this item is the top item, NO otherwise.
 */
- (void)setTitle:(NSString *)title
animated:(BOOL)animated
{
	_title								= title;
	[self updateDelegateAnimated:animated];
}

@end
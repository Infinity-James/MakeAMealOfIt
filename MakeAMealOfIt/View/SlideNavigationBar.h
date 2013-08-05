//
//  SlideNavigationToolbar.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 09/07/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Slide Navigation Bar Public Interface

@interface SlideNavigationBar : UIView {}

#pragma mark - Public Properties

/**	A Boolean value that indicates whether the toolbar is translucent (YES) or not (NO).	*/
@property (nonatomic, assign)	BOOL	translucent;

#pragma mark - Public Methods

/**
 *	Sets the items on the toolbar by animating the changes.
 *
 *	@param	items						The items to display on the toolbar.
 *	@param	animated					A Boolean value if set to YES animates the transition to the items; otherwise, does not.
 */
- (void)setItems:(NSArray *)items
		animated:(BOOL)animated;

@end
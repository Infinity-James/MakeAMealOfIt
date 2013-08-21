//
//  UIView+AlphaControl.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 10/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - UIView Alpha Control Public Interface

@interface UIView (AlphaControl) {}

#pragma mark - Public Methods

/**
 *	Sets the Boolean value that determines whether the view is hidden.
 *
 *	@param	hidden						A Boolean value that determines whether the view is hidden.
 *	@param	animated					Whether to animate the hiding of the view.
 */
- (void)setHidden:(BOOL)hidden
		 animated:(BOOL)animated;
/**
 *	Sets a view and all of it's subviews to a specified alpha.
 *
 *	@param	alpha						The alpha value for all of the views.
 */
- (void)setViewHierarchyAlpha:(CGFloat)alpha;

@end
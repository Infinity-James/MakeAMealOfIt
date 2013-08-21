//
//  UIView+AlphaControl.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 10/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UIView+AlphaControl.h"

#pragma mark - UIView Alpha Control Implementation

@implementation UIView (AlphaControl)

/**
 *	Sets the Boolean value that determines whether the view is hidden.
 *
 *	@param	hidden						A Boolean value that determines whether the view is hidden.
 *	@param	animated					Whether to animate the hiding of the view.
 */
- (void)setHidden:(BOOL)hidden
		 animated:(BOOL)animated
{
	if (!hidden)
		self.alpha						= 0.0f,
		self.hidden						= hidden;
	
	[UIView animateWithDuration:animated ? 1.0f : 0.0f
					 animations:
	 ^{
		 self.alpha						= hidden ? 0.0f : 1.0f;
	 }
					 completion:^(BOOL finished)
	 {
		 if (hidden)
			 self.hidden				= hidden;
	 }];
}

/**
 *	Sets a view and all of it's subviews to a specified alpha.
 *
 *	@param	alpha						The alpha value for all of the views.
 */
- (void)setViewHierarchyAlpha:(CGFloat)alpha
{
	self.alpha							= alpha;
	
	for (UIView *subview in self.subviews)
		[subview setViewHierarchyAlpha:alpha];
}

@end
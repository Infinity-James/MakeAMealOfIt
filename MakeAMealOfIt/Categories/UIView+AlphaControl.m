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
 *	sets a view and all of it's subviews to a specified alpha
 *
 *	@param	alpha						the alpha value for all of the views
 */
- (void)setViewHierarchyAlpha:(CGFloat)alpha
{
	self.alpha							= alpha;
	
	for (UIView *subview in self.subviews)
		[subview setViewHierarchyAlpha:alpha];
}

@end
//
//  UIView+AutolayoutHelper.m
//  BlueLibrary
//
//  Created by James Valaitis on 17/09/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UIView+AutolayoutHelper.h"

#pragma mark - UIView with Autolayout Helper Implementation

@implementation UIView (AutolayoutHelper)

#pragma mark - Utility Methods

/**
 *	Adds a view to the end of the receiver’s list of subviews to be positioned using autolayout.
 *
 *	@param	subview						The view to be added. After being added, this view appears on top of any other subviews.
 */
- (void)addSubviewForAutoLayout:(UIView *)subview
{
	subview.translatesAutoresizingMaskIntoConstraints	= NO;
	[self addSubview:subview];
}

@end

//
//  UIView+AutolayoutHelper.h
//  BlueLibrary
//
//  Created by James Valaitis on 17/09/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - UIView with Autolayout Helper Public Interface

@interface UIView (AutolayoutHelper) {}

#pragma mark - Public Methods

/**
 *	Adds a view to the end of the receiver’s list of subviews to be positioned using autolayout.
 *
 *	@param	subview						The view to be added. After being added, this view appears on top of any other subviews.
 */
- (void)addSubviewForAutoLayout:(UIView *)subview;

@end
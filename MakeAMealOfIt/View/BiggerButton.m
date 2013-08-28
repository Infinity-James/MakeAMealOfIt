//
//  BiggerButton.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "BiggerButton.h"

@implementation BiggerButton

/**
 *	Returns the farthest descendant of the receiver in the view hierarchy (including itself) that contains a specified point.
 *
 *	@param	point						A point specified in the receiver’s local coordinate system (bounds).
 *	@param	event						The event that warranted a call to this method.
 *
 *	@return	The view object that is the farthest descendent the current view and contains point.
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	CGFloat padding						= 16.0f;
	
	CGRect paddedFrame					= CGRectMake(0.0f - padding, 0.0f - padding,
													 self.bounds.size.width + (padding * 2.0f), self.bounds.size.height + (padding * 2.0f));
	
    return CGRectContainsPoint(paddedFrame, point) ? self : [super hitTest:point withEvent:event];
}

@end
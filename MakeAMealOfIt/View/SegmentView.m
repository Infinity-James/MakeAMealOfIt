//
//  SegmentView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "SegmentView.h"

#pragma mark - Segment View Private Class Extension

@interface SegmentView () {}

@end

#pragma mark - Segment View Implementation

@implementation SegmentView {}

#pragma mark - UIView Methods

/**
 *	draws the receiver’s image within the passed-in rectangle
 *
 *	@param	rect						portion of the view’s bounds that needs to be updated
 */
- (void)drawRect:(CGRect)rect
{
	//	get the context
	CGContextRef context				= UIGraphicsGetCurrentContext();
	
	//	----	fiil the rect with a background colour first of all	----
	
	//	set fill colour and then fill the rect
	UIColor *backgroundColour			= [UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:1.0f];
	CGContextSetFillColorWithColor(context, backgroundColour.CGColor);
	CGContextFillRect(context, rect);
}

@end
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
	
	//	----	get the points we need for ease	----
	
	CGPoint originPoint					= CGPointMake(rect.size.width, CGRectGetMidY(rect));
	
	CGFloat halfAngle					= self.angleOfSegment / 2.0f;
	CGFloat magnitude					= rect.size.width / cos(halfAngle);
	CGFloat xComponent					= magnitude * cos(halfAngle);
	CGFloat yComponent					= magnitude * sin(halfAngle);
	
	CGPoint topPoint					= CGPointMake(originPoint.x - xComponent, originPoint.x - yComponent);
	CGPoint bottomPoint					= CGPointMake(originPoint.x - xComponent, originPoint.x + yComponent);
	
	[kYummlyColourMain setStroke];
	CGContextMoveToPoint(context, originPoint.x, originPoint.y);
	CGContextAddLineToPoint(context, topPoint.x, topPoint.y);
	CGContextAddLineToPoint(context, bottomPoint.x, bottomPoint.y);
	CGContextAddLineToPoint(context, originPoint.x, originPoint.y);
	
	CGContextSetLineWidth(context, 10.0f);
	CGContextStrokePath(context);
}

@end
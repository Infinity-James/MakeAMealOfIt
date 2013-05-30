//
//  UtilityMethodsCG.m
//  
//
//  Created by James Valaitis on 25/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "UtilityMethodsCG.h"

#pragma mark - Utility CG Methods Implementation

@implementation UtilityMethodsCG {}

#pragma mark - Core Graphics

/**
 *	takes a rect and creates an arc at the bottom of it with the given height
 *
 *	@param	arcHeight					the height of the arc at the bottom fo the rect
 *	@param	rect						the rect that we want a rect at the bottom of
 */
+ (CGMutablePathRef)createArcPathWithHeight:(CGFloat)arcHeight
						   fromBottomOfRect:(CGRect)rect
{
	//	calculate the rect of the arc we're going to draw
	CGRect arcRect						= CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - arcHeight, rect.size.width, arcHeight);
	
	//	calculate the radius of the arc	= (segment_a_length + segment_b_length) / 2
	CGFloat arcRadius					= (arcRect.size.height / 2.0f) + (pow(arcRect.size.width, 2) / (8 * arcRect.size.height));
	//	calculate the centre or the whole arc with the radius
	CGPoint arcCentre					= CGPointMake(arcRect.origin.x + (arcRect.size.width / 2.0f), arcRect.origin.y + arcRadius);
	
	//	workout the angle for the part of the arc that we want cosine = adjacent / hypotenuse
	CGFloat angle						= acos((arcRect.size.width / 2) / arcRadius);
	CGFloat startAngle					= degreesToRadians(180.0f) + angle;
	CGFloat endAngle					= degreesToRadians(360.0f) - angle;
	
	//	create the arc segment path with the centre and radius and whether to make it clockwise (we don't)
	CGMutablePathRef path				= CGPathCreateMutable();
	CGPathAddArc(path, nil, arcCentre.x, arcCentre.y, arcRadius, startAngle, endAngle, NO);
	
	//	close off the part of the arc within the rect
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(rect), CGRectGetMinY(rect));
	CGPathAddLineToPoint(path, nil, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGPathAddLineToPoint(path, nil, CGRectGetMinX(rect), CGRectGetMaxY(rect));
	
	return path;
}

/**
 *	takes a rect and creates an rounded rect of the same size and origin with the given corner radius
 *
 *	@param	rect						the rect that we to make a rounded rect
 *	@param	cornerRadius				the radius for the corners of this rect
 */
+ (CGMutablePathRef)createRoundedRectFromRect:(CGRect)rect
							 withCornerRadius:(CGFloat)cornerRadius
{
	//	----	create rounded rect path	----
	
	//	create a mutable path
	CGMutablePathRef rectPath			= CGPathCreateMutable();
	
	//	start the path in the middle of the x-axis on the top of the rect
	CGPathMoveToPoint(rectPath, nil, CGRectGetMidX(rect), CGRectGetMinY(rect));
	
	
	/**
	 *	@param	path					the mutable path to change (cannot be empty)
	 *	@param	affineTransform			transformation for the arc
	 *	@param	firstTangentX (x1)		x-coordinate of end point of first tangent (first line drawn from current point to [x1, y1])
	 *	@param	firstTangentY (y1)		y-coordinate of end point of first tangent (first line drawn from current point to [x1, y1])
	 *	@param	secondTangentX (x2)		x-coordinate of end point of second tangent (second line drawn from [x1, y1] to [x2, y2])
	 *	@param	secondTangentY (y2)		y-coordinate of end point of second tangent (second line drawn from [x1, y1] to [x2, y2])
	 *	@param	arcRadius				radius of the arc
	 */
	//	first and second tangent are the top and right side of the rect (top-right corner arc)
	CGPathAddArcToPoint(rectPath, nil, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), cornerRadius);
	//	third and fourth tangent are the right and bottom side of the rect (bottom-right corner arc)
	CGPathAddArcToPoint(rectPath, nil, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), cornerRadius);
	//	fifth and sixth tangent are the bottom and left side of the rect (bottom-left corner arc)
	CGPathAddArcToPoint(rectPath, nil, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius);
	//	seventh and eigth tangent are the left and top side of the rect (top-left corner arc)
	CGPathAddArcToPoint(rectPath, nil, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), cornerRadius);
	
	//	close the path
	CGPathCloseSubpath(rectPath);
	
	return rectPath;
}

/**
 *	draws a linear gradient in the given context with the parameters passed in
 *
 *	@param	context						the context to draw the gradient in
 *	@param	rect						the rect defining the size of the gradient
 *	@param	startColour					the starting colour of the gradient
 *	@param	endColour					the end colour of the gradient
 */
+ (void)drawGlossAndGradientInContext:(CGContextRef)context
							 withRect:(CGRect)rect
						  startColour:(CGColorRef)startColour
						 andEndColour:(CGColorRef)endColour
{
	[UtilityMethodsCG drawLinearGradientInContext:context withRect:rect startColour:startColour andEndColour:endColour];
	
	UIColor *glossColourOne				= [UIColor colorWithWhite:1.0f alpha:0.35f];
	UIColor *glossColourTwo				= [UIColor colorWithWhite:1.0f alpha:0.10f];
	
	CGRect topHalf						= CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height / 2.0f);
	
	[UtilityMethodsCG drawLinearGradientInContext:context withRect:topHalf startColour:glossColourOne.CGColor andEndColour:glossColourTwo.CGColor];
}

/**
 *	draws a linear gradient in the given context with the parameters passed in
 *
 *	@param	context						the context to draw the gradient in
 *	@param	rect						the rect defining the size of the gradient
 *	@param	startColour					the starting colour of the gradient
 *	@param	endColour					the end colour of the gradient
 */
+ (void)drawLinearGradientInContext:(CGContextRef)context withRect:(CGRect)rect startColour:(CGColorRef)startColour andEndColour:(CGColorRef)endColour
{
	//	get the colour space with which we'll draw the gradient and create array tracking location of each colour
	CGColorSpaceRef colourSpace			= CGColorSpaceCreateDeviceRGB();
	CGFloat locations[]					= { 0.0f, 1.0f };
	
	//	create array of colours
	NSArray *colours					= @[(__bridge id)startColour, (__bridge id)endColour];
	
	//	create gradient by passing in colour space, colours and location of colours
	CGGradientRef gradient				= CGGradientCreateWithColors(colourSpace, (__bridge CFArrayRef)colours, locations);
	
	//	calculate start and end point of gradient in context
	CGPoint startPoint					= CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint					= CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	//	push a copy of the current graphics state onto the graphics state stack for the contex
	CGContextSaveGState(context);
	//	adds a rectangular path to the current path
	CGContextAddRect(context, rect);
	//	modifies the current clipping path to draw only within the rect added above
	CGContextClip(context);
	//	paints the gradient fill that varies along the line defined by the provided starting and ending points
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kNilOptions);
	//	sets the current graphics state to the state most recently saved
	CGContextRestoreGState(context);
	
	//	release the core graphics objects that we used to free up memory
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colourSpace);
}

/**
 *	draws a linear gradient in the given context with the parameters passed in
 *
 *	@param	context						the context to draw the gradient in
 *	@param	rect						the rect defining the size of the gradient
 *	@param	startColour					the starting colour of the gradient
 *	@param	endColour					the end colour of the gradient
 */
+ (void)drawOnePixelStrokeInContext:(CGContextRef)context
							  fromStartPoint:(CGPoint)startPoint
								  toEndPoint:(CGPoint)endPoint
									inColour:(CGColorRef)colour
{
	//	push a copy of the current graphics state onto the graphics state stack for the contex
	CGContextSaveGState(context);
	//	sets the style for the endpoints of lines drawn in a graphics context
	CGContextSetLineCap(context, kCGLineCapSquare);
	//	sets the current stroke color in a context
	CGContextSetStrokeColorWithColor(context, colour);
	//	sets the line width for a graphics context
	CGContextSetLineWidth(context, 1.0f);
	//	begins a new subpath at the point you specify
	CGContextMoveToPoint(context, startPoint.x + 0.5f, startPoint.y + 0.5f);
	//	appends a straight line segment from the current point to the provided point
	CGContextAddLineToPoint(context, endPoint.x + 0.5f, endPoint.y + 0.5f);
	//	paints a line along the current path
	CGContextStrokePath(context);
	//	sets the current graphics state to the state most recently saved
	CGContextRestoreGState(context);
}

/**
 *
 *
 *	@param	rect						the rect we used to create the one pixel stroke
 */
+ (CGRect)getOnePixelStrokeForRect:(CGRect)rect
{
	return CGRectMake(rect.origin.x + 0.5f, rect.origin.y + 0.5f, rect.size.width - 1.0f, rect.size.height - 1.0f);
}

@end
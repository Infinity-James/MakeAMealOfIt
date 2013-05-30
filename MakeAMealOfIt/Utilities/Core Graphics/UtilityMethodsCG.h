//
//  UtilityMethodsCG.h
//  
//
//  Created by James Valaitis on 25/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Defined Constants

//	convenience math methods
#define radiansToDegrees(x)			x * 180.0f / M_PI
#define degreesToRadians(x)			x * M_PI / 180.0f

#pragma mark - Utility CG Methods Public Interface

@interface UtilityMethodsCG : NSObject {}

#pragma mark - Public Methods

+ (CGMutablePathRef)createArcPathWithHeight:(CGFloat)arcHeight
						   fromBottomOfRect:(CGRect)rect;
+ (CGMutablePathRef)createRoundedRectFromRect:(CGRect)rect
								   withCornerRadius:(CGFloat)cornerRadius;
+ (void)drawGlossAndGradientInContext:(CGContextRef)context
							 withRect:(CGRect)rect
						  startColour:(CGColorRef)startColour
						 andEndColour:(CGColorRef)endColour;
+ (void)drawLinearGradientInContext:(CGContextRef)context
						   withRect:(CGRect)rect
						startColour:(CGColorRef)startColour
					   andEndColour:(CGColorRef)endColour;
+ (void)drawOnePixelStrokeInContext:(CGContextRef)context
					 fromStartPoint:(CGPoint)startPoint
						 toEndPoint:(CGPoint)endPoint
						   inColour:(CGColorRef)colour;
+ (CGRect)getOnePixelStrokeForRect:(CGRect)rect;

@end
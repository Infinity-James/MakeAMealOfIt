//
//  StarRatingView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 31/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "StarRatingView.h"

@interface StarRatingView () {}

@end

#pragma mark - Star Rating View Implementation

@implementation StarRatingView

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 *
 *	@param	rating						the rating for this view to present
 */
- (instancetype)initWithRating:(CGFloat)rating
{
	if (self = [super init])
	{
		self.rating						= rating;
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *	set the rating for this view to present
 *
 *	@param	rating						the rating for the stars to show
 */
- (void)setRating:(CGFloat)rating
{
	//	round every rating to the nearest .5
	_rating								= roundf(rating * 2.0f) / 2.0f;
}

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
	
	CGContextSetFillColorWithColor(context, kYummlyColourMain.CGColor);
	CGContextSetStrokeColorWithColor(context, kYummlyColourMain.CGColor);
	
	// constants
    CGFloat	width						= rect.size.width;
    CGFloat radius						= width / 2.0f;
    CGFloat theta						= 2.0f * M_PI * (2.0f / 5.0f);
    CGFloat flip						= -1.0f; // flip vertically (default star representation)
	
    // drawing center for the star
    CGFloat xCenter						= radius;
	
    for (NSUInteger index = 0; index < self.rating; index++)
    {
		CGFloat starOffset				= width * index + radius;
		
        // update position
        CGContextMoveToPoint(context, xCenter, (radius * flip) + starOffset);
		
        // draw the necessary star lines
        for (NSUInteger point = 1; point < 5; point++)
        {
            CGFloat x					= radius * sin(point * theta);
            CGFloat y					= radius * cos(point * theta);
            CGContextAddLineToPoint(context, x + xCenter, (y * flip) + starOffset);
        }

        // draw current star
        CGContextClosePath(context);
        CGContextFillPath(context);
        CGContextStrokePath(context);
    }
}

#pragma mark - View-Related Observation Methods

/**
 *	Tells the view that its superview changed.
 */
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	self.backgroundColor				= [UIColor whiteColor];
}

@end















































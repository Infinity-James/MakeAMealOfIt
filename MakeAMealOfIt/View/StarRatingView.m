//
//  StarRatingView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 31/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "StarRatingView.h"

@interface StarRatingView () {}

@property (nonatomic, assign)	CGFloat	rating;

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
	
	UIColor *endColour					= kYummlyColourShadowWithAlpha(1.0f);
	UIColor *startColour				= kYummlyColourMainWithAlpha(0.0f);
	
	//	----	fiil the rect with a background colour first of all	----
	
	//	set fill colour and then fill the rect
	[UtilityMethodsCG drawLinearGradientInContext:context withRect:rect startColour:startColour.CGColor andEndColour:endColour.CGColor];
}

@end
//
//  RecipeCollectionViewCell.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 24/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeCollectionViewCell.h"

#pragma mark - Recipe Collection View Cell Private Class Extension

@interface RecipeCollectionViewCell () {}

#pragma mark - Private Properties

@end

#pragma mark - Recipe Collection View Cell Implementation

@implementation RecipeCollectionViewCell {}

#pragma mark - Auto Layout Methods

/**
 *	Returns whether the receiver depends on the constraint-based layout system.
 *
 *	@return	YES if the view must be in a window using constraint-based layout to function properly, NO otherwise.
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	Update constraints for the view.
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self.contentView removeConstraints:self.contentView.constraints];
	[self.thumbnailView removeConstraints:self.thumbnailView.constraints];
	
	NSLayoutConstraint *constraint;
	NSArray *constraints;
	
	NSDictionary *layoutMetrics			= @{@"margin": @14.0f};
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeDetails
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:self.contentView
													attribute:NSLayoutAttributeHeight
												   multiplier:0.3f
													 constant:0.0f];
	[self.contentView addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[recipeDetails]-(margin)-|"
																options:NSLayoutFormatAlignAllCenterX
																metrics:layoutMetrics
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[recipeDetails]-(margin)-|"
																options:kNilOptions
																metrics:layoutMetrics
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	[self.contentView addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[thumbnail]-(margin)-|"
																options:NSLayoutFormatAlignAllCenterX
																metrics:layoutMetrics
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[thumbnail]-(margin)-|"
																options:kNilOptions
																metrics:layoutMetrics
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 *	@param	frame						The frame rectangle for the view, measured in points.
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		self.backgroundColor			= [UIColor whiteColor];
    }
	
    return self;
}


#pragma mark - Setter & Getter Methods

/**
 *	The view that will contain the recipe title and source name.
 *
 *	@return	An initialised view specifically for holding the recipe details.
 */
- (TextBackingView *)recipeDetails
{
	if (!_recipeDetails)
	{
		_recipeDetails					= [[TextBackingView alloc] init];
		
		_recipeDetails.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_recipeDetails];
	}
	
	return _recipeDetails;
}

/**
 *	This thumbnail view will display a small image of the recipe.
 *
 *	@return	An initialised UIImageView added to the content view.
 */
- (UIImageView *)thumbnailView
{
	if (!_thumbnailView)
	{
		_thumbnailView					= [[UIImageView alloc] initWithFrame:CGRectZero];
		_thumbnailView.contentMode		= UIViewContentModeScaleToFill;
		
		_thumbnailView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_thumbnailView];
		[self.contentView sendSubviewToBack:_thumbnailView];
	}
	
	return _thumbnailView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"recipeDetails"	: self.recipeDetails,
				@"thumbnail"		: self.thumbnailView};
}

#pragma mark - UIView Methods

/**
 *	draws the receiver’s image within the passed-in rectangle
 *
 *	@param	rect						portion of the view’s bounds that needs to be updated
 *
 - (void)drawRect:(CGRect)rect
{
	//	get the context
	CGContextRef context				= UIGraphicsGetCurrentContext();
	 
	//	----	fiil the rect with a background colour first of all	----
	 
	//	set fill colour and then fill the rect
	[kYummlyColourMain setStroke];
	CGMutablePathRef borderPath= CGPathCreateMutable();
	CGContextSetShadowWithColor(context, kShadowOffset, kShadowBlur, kShadowColour.CGColor);
	CGPathMoveToPoint(borderPath, nil, rect.origin.x + 10.0f, rect.origin.y + 10.0f);
	CGPathAddLineToPoint(borderPath, nil, rect.origin.x + 10.0f, rect.size.height - 10.0f);
	CGPathAddLineToPoint(borderPath, nil, rect.size.width - 10.0f, rect.size.height - 10.0f);
	CGPathAddLineToPoint(borderPath, nil, rect.size.width - 10.0f, rect.origin.y + 10.0f);
	CGPathAddLineToPoint(borderPath, nil, rect.origin.x + 10.0f, rect.origin.y + 10.0f);
	CGContextAddPath(context, borderPath);
	CGContextStrokePath(context);
	CGPathRelease(borderPath);
}*/

@end
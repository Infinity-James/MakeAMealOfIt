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

/**	A label that indicates that this cell is currently highlighted.	*/
@property (nonatomic, strong)	UIImageView		*highlightedIndicator;

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
	
	NSDictionary *layoutMetrics			= @{@"margin": @(self.contentView.bounds.size.height / 20.0f)};
	
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
	
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[highlightedIndicator]-(8)-|"
																			 options:kNilOptions
																			 metrics:nil
																			   views:self.viewsDictionary]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[highlightedIndicator]"
																			 options:kNilOptions
																			 metrics:nil
																			   views:self.viewsDictionary]];
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
    }
	
    return self;
}


#pragma mark - Property Accessor Methods - Getters

/**
 *	A label containing a tick that shows this cell has been selected.
 *
 *	@return	An initialised UILabel to be used on a highlighted cell.
 */
- (UIImageView *)highlightedIndicator
{
	if (!_highlightedIndicator)
	{
		UIImage *image								= [UIImage imageNamed:@"image_checkmark"];
		image										= [[UIImage alloc] initWithCGImage:image.CGImage scale:image.scale * 2.0f orientation:image.imageOrientation];
		
		_highlightedIndicator						= [[UIImageView alloc] initWithImage:image];
		
		_highlightedIndicator.backgroundColor		= [UIColor whiteColor];
		_highlightedIndicator.hidden				= !self.highlighted;
		_highlightedIndicator.layer.borderColor		= kDarkGreyColour.CGColor;
		_highlightedIndicator.layer.borderWidth		= 1.0f;
		_highlightedIndicator.layer.cornerRadius	= image.size.height / 2.0f;
		
		_highlightedIndicator.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.contentView addSubview:_highlightedIndicator];
	}
	
	return _highlightedIndicator;
}

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
		_recipeDetails.clipsToBounds	= YES;
		
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
	return @{	@"highlightedIndicator"	: self.highlightedIndicator,
				@"recipeDetails"	: self.recipeDetails,
				@"thumbnail"		: self.thumbnailView};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	A convenient way to get the correct background colour for a certain index.
 *
 *	@param	index						The index of the cell for which to return the colour.
 */
- (void)setBackgroundColourForIndex:(NSUInteger)index
{
	UIColor *backgroundColour;
	
	if (index % 3 == 0)
		backgroundColour				= [[UIColor alloc] initWithRed:011.0f / 255.0f green:156.0f / 255.0f blue:218.0f / 255.0f alpha:1.0f];
	else if (index % 3 == 2)
		backgroundColour				= kYummlyColourMain;
	else
		backgroundColour				= kLightGreyColour;
	
	self.backgroundColor				= backgroundColour;
}

/**
 *	The highlight state of the cell.
 *
 *	@param	highlighted					The desired highlight state of the cell.
 */
- (void)setHighlighted:(BOOL)highlighted
{
	self.highlightedIndicator.hidden		= highlighted ? NO : YES;
	
	[super setHighlighted:highlighted];
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
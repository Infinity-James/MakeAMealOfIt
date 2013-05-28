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

@property (nonatomic, strong)	NSDictionary	*viewsDictionary;

@end

#pragma mark - Recipe Collection View Cell Implementation

@implementation RecipeCollectionViewCell {}

#pragma mark - Auto Layout Methods

/**
 *	returns whether the receiver depends on the constraint-based layout system
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	update constraints for the view
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self.contentView removeConstraints:self.contentView.constraints];
	[self.thumbnailView removeConstraints:self.thumbnailView.constraints];
	
	NSLayoutConstraint *constraint;
	NSArray *constraints;
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeDetails
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:self.contentView
													attribute:NSLayoutAttributeHeight
												   multiplier:0.4f
													 constant:0.0f];
	[self.contentView addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[recipeDetails]|"
																options:NSLayoutFormatAlignAllCenterX
																metrics:nil
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[recipeDetails]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	[self.contentView addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[thumbnail]-|"
																options:NSLayoutFormatAlignAllCenterX
																metrics:nil
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[thumbnail]-|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.contentView addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	initializes and returns a newly allocated view object with the specified frame rectangle
 *
 *	@param	frame						frame rectangle for the view, measured in points
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
 *
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
 *	this thumbnail view will display a small image of the recipe
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
 *	this dictionary is used when laying out constraints
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
 */
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
}

@end
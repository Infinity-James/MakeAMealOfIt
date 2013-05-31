//
//  RecipeDetailsView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsView.h"

#pragma mark - Recipe Details View Private Class Extension

@interface RecipeDetailsView () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	Recipe				*recipe;
@property (nonatomic, strong)	UIImageView			*recipeImageView;
@property (nonatomic, strong)	NSDictionary		*viewsDictionary;

@end

#pragma mark - Recipe Details View Implementation

@implementation RecipeDetailsView {}

#pragma mark - Autolayout Methods

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
	
	//	remove all constraints
	[self removeConstraints:self.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add the recipe image view to span the view horizontally
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[recipeImageView]-|"
																options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self addConstraints:constraints];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[recipeImageView]"
																options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self addConstraints:constraints];
	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeImageView
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:self.recipeImageView
													attribute:NSLayoutAttributeWidth
												   multiplier:1.0f
													 constant:0.0f];
	[self.recipeImageView addConstraint:constraint];
}

#pragma mark - Convenience & Helper Methods

/**
 *	sets all of the views to nil
 */
- (void)nilifyAllViews
{
	self.recipeImageView				= nil;
}

#pragma mark - Initialisation
/**
 *	called to initialise a class instance
 */
- (instancetype)initWithRecipe:(Recipe *)recipe;
{
	if (self = [super init])
	{
		self.recipe						= recipe;
		self.recipe.delegate			= self;
	}
	
	return self;
}

#pragma mark - Recipe Delegate Methods

/**
 *	called when the recipe loaded it's details
 */
- (void)recipeDictionaryHasLoaded
{
	[self nilifyAllViews];
	[self setNeedsUpdateConstraints];
}

#pragma mark - Setter & Getter Methods

/**
 *	the image view holding the main image for the recipe being represented
 */
- (UIImageView *)recipeImageView
{
	if (!_recipeImageView)
	{
		_recipeImageView				= [[UIImageView alloc] initWithImage:self.recipe.recipeImage];
		_recipeImageView.contentMode	= UIViewContentModeScaleToFill;
		
		_recipeImageView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_recipeImageView];
	}
	
	return _recipeImageView;
}

/**
 *	this dictionary is used when laying out constraints
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"recipeImageView"	: self.recipeImageView	};
}

@end
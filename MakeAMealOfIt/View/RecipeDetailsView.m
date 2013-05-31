//
//  RecipeDetailsView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsView.h"
#import "UIImageView+Animation.h"

#pragma mark - Recipe Details View Private Class Extension

@interface RecipeDetailsView () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UIActivityIndicatorView		*activityIndicatorView;
@property (nonatomic, strong)	Recipe						*recipe;
@property (nonatomic, strong)	UIImageView					*recipeImageView;
@property (nonatomic, strong)	NSDictionary				*viewsDictionary;

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
	[self.recipeImageView removeConstraints:self.recipeImageView.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add the recipe image view and set the width and height
	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeImageView
													attribute:NSLayoutAttributeWidth
													relatedBy:NSLayoutRelationEqual
													   toItem:nil
													attribute:NSLayoutAttributeNotAnAttribute
												   multiplier:1.0f
													 constant:200.0f];
	[self.recipeImageView addConstraint:constraint];

	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeImageView
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
	[self addConstraint:constraint];
	
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
	[self.activityIndicatorView startAnimating];
	dispatch_async(dispatch_queue_create("Recipe Photo Fetcher", NULL),
	^{
		UIImage *image					= self.recipe.recipeImage;
		
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.activityIndicatorView stopAnimating];
			[self.recipeImageView setImage:image animated:YES];
			[self setNeedsUpdateConstraints];
		});
	});
}

#pragma mark - Setter & Getter Methods

/**
 *	this will indicate that the image view is loading
 */
- (UIActivityIndicatorView *)activityIndicatorView
{
	if (!_activityIndicatorView)
	{
		_activityIndicatorView			= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicatorView.color	= kYummlyColourMain;
		
		[self addSubview:_activityIndicatorView];
	}
	
	return _activityIndicatorView;
}

/**
 *	the image view holding the main image for the recipe being represented
 */
- (UIImageView *)recipeImageView
{
	if (!_recipeImageView)
	{
		_recipeImageView				= [[UIImageView alloc] init];
		_recipeImageView.contentMode	= UIViewContentModeScaleToFill;
		[_recipeImageView addShadow];
		
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
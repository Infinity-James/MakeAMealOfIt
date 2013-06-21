//
//  RecipeDetailsView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsView.h"
#import "StarRatingView.h"
#import "UIImageView+Animation.h"

static CGFloat const kImageHeight		= 200.0f;

#pragma mark - Recipe Details View Private Class Extension

@interface RecipeDetailsView () {}

#pragma mark - Private Properties

@property (nonatomic, strong)				UIActivityIndicatorView		*activityIndicatorView;
@property (nonatomic, readwrite, strong)	Recipe						*recipe;
@property (nonatomic, strong)				UIImageView					*recipeImageView;
@property (nonatomic, strong)				StarRatingView				*starRatingView;
@property (nonatomic, strong)				NSDictionary				*viewsDictionary;

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
 *	Adds the activity indicator view over the image view.
 */
- (void)addConstraintsForActivityIndicatorView
{
	NSLayoutConstraint *constraint;
	NSArray *constraints;
	
	CGFloat imageMargin					= 20.0f + (kImageHeight / 2.0f);
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.activityIndicatorView
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
	[self addConstraint:constraint];
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(imageMargin)-[activityIndicator]"
																options:kNilOptions
																metrics:@{@"imageMargin": @(imageMargin)}
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
}

/**
 *
 */
- (void)addConstraintsForStarRatingView
{
	NSLayoutConstraint *constraint;
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.starRatingView
													attribute:NSLayoutAttributeWidth
													relatedBy:NSLayoutRelationEqual
													   toItem:nil
													attribute:NSLayoutAttributeNotAnAttribute
												   multiplier:1.0f
													 constant:kImageHeight];
	[self.starRatingView addConstraint:constraint];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.starRatingView
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:self.starRatingView
													attribute:NSLayoutAttributeWidth
												   multiplier:0.2f
													 constant:0.0f];
	[self.starRatingView addConstraint:constraint];
}

/**
 *	Update constraints for the view.
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	//	remove all constraints
	[self removeConstraints:self.constraints];
	[self.recipeImageView removeConstraints:self.recipeImageView.constraints];
	[self.starRatingView removeConstraints:self.starRatingView.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add the recipe image view and set the width and height
	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeImageView
													attribute:NSLayoutAttributeWidth
													relatedBy:NSLayoutRelationEqual
													   toItem:nil
													attribute:NSLayoutAttributeNotAnAttribute
												   multiplier:1.0f
													 constant:kImageHeight];
	[self.recipeImageView addConstraint:constraint];

	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeImageView
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
	[self addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[recipeImageView]-[starRating]"
																options:NSLayoutFormatAlignAllCenterX
																metrics:nil
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeImageView
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:self.recipeImageView
													attribute:NSLayoutAttributeWidth
												   multiplier:1.0f
													 constant:0.0f];
	[self.recipeImageView addConstraint:constraint];
	
	[self addConstraintsForActivityIndicatorView];
	[self addConstraintsForStarRatingView];
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
		
		_activityIndicatorView.translatesAutoresizingMaskIntoConstraints	= NO;
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
 *	this view represent the recipe's rating
 */
- (StarRatingView *)starRatingView
{
	if (!_starRatingView)
	{
		_starRatingView					= [[StarRatingView alloc] initWithRating:self.recipe.rating];
		
		_starRatingView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_starRatingView];
	}
	
	return _starRatingView;
}

/**
 *	This dictionary is used when laying out constraints.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"activityIndicator"	: self.activityIndicatorView,
				@"recipeImageView"		: self.recipeImageView,
				@"starRating"			: self.starRatingView	};
}

@end
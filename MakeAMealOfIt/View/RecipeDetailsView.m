//
//  RecipeDetailsView.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsView.h"
#import "RecipeIngredientsController.h"
#import "StarRatingView.h"
#import "UIImageView+Animation.h"

#pragma mark - Constants & Static Variables

/**	The height for the image in this view.	*/
static CGFloat const kImageHeight		= 200.0f;

#pragma mark - Recipe Details View Private Class Extension

@interface RecipeDetailsView () <RecipeIngredientsControllerDelegate> {}

#pragma mark - Private Properties

/**	Used to show that the recipe image is loading.	*/
@property (nonatomic, strong)				UIActivityIndicatorView		*activityIndicatorView;
/**	*/
@property (nonatomic, strong)				UITableView					*ingredientsTableView;
/**	An object encapsulating the recipe that this view is showing.	*/
@property (nonatomic, readwrite, strong)	Recipe						*recipe;
/**	The view responsible for showing the image of the recipe being displayed.	*/
@property (nonatomic, strong)				UIImageView					*recipeImageView;
/**	A controller that will handle displaying the ingredients in the table view properly.	*/
@property (nonatomic, strong)				RecipeIngredientsController	*recipeIngredientsController;
/**	A view showing the rating of the recipe being displayed.	*/
@property (nonatomic, strong)				StarRatingView				*starRatingView;

@end

#pragma mark - Recipe Details View Implementation

@implementation RecipeDetailsView {}

#pragma mark - Autolayout Methods

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
	
	//	remove all constraints
	[self removeConstraints:self.constraints];
	[self.recipeImageView removeConstraints:self.recipeImageView.constraints];
	[self.starRatingView removeConstraints:self.starRatingView.constraints];
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[recipeImageView]|"
																options:NSLayoutFormatAlignAllCenterX
																metrics:nil
																  views:self.viewsDictionary];
	[self addConstraints:constraints];

	constraint							= [NSLayoutConstraint constraintWithItem:self.recipeImageView
													attribute:NSLayoutAttributeCenterX
													relatedBy:NSLayoutRelationEqual
													   toItem:self
													attribute:NSLayoutAttributeCenterX
												   multiplier:1.0f
													 constant:0.0f];
	[self addConstraint:constraint];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[recipeImageView]-[tableView(==tvHeight)]"
																options:kNilOptions
																metrics:@{@"tvHeight": @(self.recipeIngredientsController.maximumTableViewHeight)}
																  views:self.viewsDictionary];
	[self addConstraints:constraints];
	
	CGFloat tableViewWidth				= (self.bounds.size.width / 5.0f) * 3.0f;
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tableView(==tvWidth)]-[starRating]"
																options:NSLayoutFormatAlignAllTop
																metrics:@{@"tvWidth": @(tableViewWidth)}
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
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.starRatingView
													attribute:NSLayoutAttributeHeight
													relatedBy:NSLayoutRelationEqual
													   toItem:nil
													attribute:NSLayoutAttributeNotAnAttribute
												   multiplier:1.0f
													 constant:kImageHeight];
	[self.starRatingView addConstraint:constraint];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.starRatingView
													attribute:NSLayoutAttributeWidth
													relatedBy:NSLayoutRelationEqual
													   toItem:self.starRatingView
													attribute:NSLayoutAttributeHeight
												   multiplier:0.2f
													 constant:0.0f];
	[self.starRatingView addConstraint:constraint];
}

#pragma mark - Convenience & Helper Methods

/**
 *	Sets all of the views to nil.
 */
- (void)nilifyAllViews
{
	self.ingredientsTableView			= nil;
	self.recipeImageView				= nil;
	self.recipeIngredientsController	= nil;
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@param	recipe						The recipe object being represented by this view.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithRecipe:(Recipe *)recipe;
{
	if (self = [super init])
	{
		self.recipe						= recipe;
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The view that shows the user that the recipe image is loading.
 *
 *	@return	A UIActivityIndicatorView representing loading.
 */
- (UIActivityIndicatorView *)activityIndicatorView
{
	if (!_activityIndicatorView)
	{
		_activityIndicatorView			= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicatorView.center	= self.center;
		_activityIndicatorView.color	= kYummlyColourMain;
		
		_activityIndicatorView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_activityIndicatorView];
	}
	
	return _activityIndicatorView;
}

/**
 *	A table view that will display the ingredients required for the recipe being displayed.
 *
 *	@return	An initialised table view ready to display ingredients.
 */
- (UITableView *)ingredientsTableView
{
	if (!_ingredientsTableView)
	{
		_ingredientsTableView			= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		
		if (self.recipe.ingredientLines)
		{
			_ingredientsTableView.dataSource	= self.recipeIngredientsController;
			_ingredientsTableView.delegate		= self.recipeIngredientsController;
		}
		
		_ingredientsTableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
		
		[_ingredientsTableView registerClass:[RecipeDetailsIngredientCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_ingredientsTableView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_ingredientsTableView];
	}
	
	return _ingredientsTableView;
}

/**
 *	The view responsible for showing the image of the recipe being displayed.
 *
 *	@return	A UIImageView initialised to hold an image of the recipe.
 */
- (UIImageView *)recipeImageView
{
	if (!_recipeImageView)
	{
		_recipeImageView				= [[UIImageView alloc] init];
		_recipeImageView.contentMode	= UIViewContentModeScaleToFill;
		//[_recipeImageView addShadow];
		
		_recipeImageView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_recipeImageView];
	}
	
	return _recipeImageView;
}

/**
 *	A controller that will handle displaying the ingredients in the table view properly.
 *
 *	@return	An initialised RecipeIngredientsController with the ingredients it needs to display in the table view.
 */
- (RecipeIngredientsController *)recipeIngredientsController
{
	if (!_recipeIngredientsController)
	{
		_recipeIngredientsController	= [[RecipeIngredientsController alloc] initWithIngredients:self.recipe.ingredientLines];
		_recipeIngredientsController.delegate	= self;
	}
	
	return _recipeIngredientsController;
}

/**
 *	A view that shows stars and half stars pertaining to the recipe rating.
 *
 *	@return	A view used to display the rating of the recipe.
 */
- (StarRatingView *)starRatingView
{
	if (!_starRatingView)
	{
		_starRatingView					= [[StarRatingView alloc] initWithRating:self.recipe.rating];
		_starRatingView.hidden			= YES;
		
		_starRatingView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_starRatingView];
	}
	
	return _starRatingView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"activityIndicator"	: self.activityIndicatorView,
				@"recipeImageView"		: self.recipeImageView,
				@"starRating"			: self.starRatingView,
				@"tableView"			: self.ingredientsTableView		};
}

#pragma mark - RecipeIngredientsControllerDelegate Methods

/**
 *	Sent to the delegate when the maximum height for the table view displaying the ingredient has been calculated.
 */
- (void)tableViewHeightCalculated
{
	if ([self.delegate respondsToSelector:@selector(updatedIntrinsicContentSize)])
		[self.delegate updatedIntrinsicContentSize];
	
	self.starRatingView.hidden			= NO;
	[self setNeedsUpdateConstraints];
}

#pragma mark - UIView Methods

/**
 *	Returns the natural size for the receiving view, considering only properties of the view itself.
 *
 *	@return	A size indicating the natural size for the receiving view based on its intrinsic properties.
 */
- (CGSize)intrinsicContentSize
{
	CGSize contentSize					= self.superview.bounds.size;
	contentSize.height					= self.recipeImageView.frame.size.height + self.recipeIngredientsController.maximumTableViewHeight + 300.0f;
	
	return contentSize;
}

#pragma mark - Utility Methods

/**
 *	Called when the recipe loaded it's details.
 */
- (void)recipeDictionaryHasLoaded
{
	[self nilifyAllViews];
	
	dispatch_async(dispatch_get_main_queue(),
	^{
		[self.activityIndicatorView startAnimating];
		self.starRatingView.rating		= self.recipe.rating;
		[self.starRatingView setNeedsDisplay];
		NSLog(@"RATING: %f", self.recipe.rating);
					   
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
	});
}

@end
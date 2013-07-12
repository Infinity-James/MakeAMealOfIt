//
//  RecipeDetailsViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "RecipeDetailsView.h"
#import "ToolbarLabelYummlyTheme.h"
#import "YummlyAPI.h"

#pragma mark - Recipe Details VC Private Class Extension

@interface RecipeDetailsViewController () <RecipeDelegate> {}

#pragma mark - Private Properties

/**	*/
@property (nonatomic, copy)		AttributionDictionaryLoaded	attributionDictionaryLoaded;
/**	*/
@property (nonatomic, strong)	Recipe						*recipe;
/**	*/
@property (nonatomic, strong)	RecipeDetailsView			*recipeDetailsView;
/**	*/
@property (nonatomic, strong)	NSString					*recipeID;
/**	*/
@property (nonatomic, strong)	NSString					*recipeName;
/**	The right toolbar button used to slide in the right view	*/
@property (nonatomic, strong)	UIBarButtonItem				*rightButton;
/**	*/
@property (nonatomic, strong)	UIScrollView				*scrollView;

@end

#pragma mark - Recipe Details VC Implementation

@implementation RecipeDetailsViewController {}

#pragma mark - Action & Selector Methods

/**
 *	Called when the button in the toolbar for the right panel is tapped.
 */
- (void)rightButtonTapped
{
	if (self.slideNavigationController.controllerState == SlideNavigationSideControllerClosed)
		[self.slideNavigationController setControllerState:SlideNavigationSideControllerRightOpen withCompletionHandler:nil];
}

#pragma mark - Autolayout Methods

/**
 *	Called when the view controller’s view needs to update its constraints.
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	NSArray *constraints;
	
	//	add the collection view to cover the whole main view except for the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==44)-[scrollView]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Initialisation

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animated					Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animated
{	
	[self.slideNavigationItem setRightBarButtonItem:self.rightButton animated:animated];
	[self.slideNavigationItem setTitle:self.recipeName animated:animated];
}

/**
 *	Called to initialise an instance of this class with an ID of a recipe to present as well as it's name.
 *
 *	@param	recipeID					The ID of the recipe this view controller will show through it's views.
 *	@param	recipeName					The name of the recipe this view controller wil show.
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
				   andRecipeName:(NSString *)recipeName
{
	if (self = [super init])
	{
		self.recipeID					= recipeID;
		self.recipeName					= recipeName;
	}
	
	return self;
}

#pragma mark - Recipe Delegate Methods

/**
 *	Called when the recipe loaded it's details.
 */
- (void)recipeDictionaryHasLoaded
{
	[self.recipeDetailsView recipeDictionaryHasLoaded];
	
	//	notify the right view controller that the attribution dictionary has been loaded
	if (self.attributionDictionaryLoaded)
		self.attributionDictionaryLoaded(self.recipe.attributionDictionary);
}

#pragma mark - RightControllerDelegate Methods

/**
 *	Called to get the attribution dictionary for the recipe being shown in the delegate.
 *
 *	@return	A dictionary with the details required for correct attribution for a recipe.
 */
- (NSDictionary *)attributionDictionaryForCurrentRecipe
{
	return self.recipe.attributionDictionary;
}

/**
 *
 *
 *	@param
 */
- (void)blockToCallWithAttributionDictionary:(AttributionDictionaryLoaded)attributionDictionaryLoaded
{
	if (self.recipe.attributionDictionary)
		attributionDictionaryLoaded(self.recipe.attributionDictionary);
	else
		self.attributionDictionaryLoaded= attributionDictionaryLoaded;
}

/**
 *	Called when the user has updated selections available in the right view controller/
 *
 *	@param	rightViewController			The right view updated with selections.
 *	@param	selections					A dictionary of selection updates in the right view controller.
 */
- (void)rightController:(UIViewController *)rightViewController
  updatedWithSelections:(NSDictionary *)selections
{
	
}

#pragma mark - Setter & Getter Methods

/**
 *	this view lives inside of the scroll view and shows everything to do with the selected recipe
 */
- (RecipeDetailsView *)recipeDetailsView
{
	if (!_recipeDetailsView)
	{
		_recipeDetailsView				= [[RecipeDetailsView alloc] initWithRecipe:self.recipe];
		_recipeDetailsView.frame		= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 500.0f);
	}
	
	return _recipeDetailsView;
}

/**
 *	The right slide navigation bar button used to slide in the right view.
 *
 *	@return	An initialised and targeted UIBarButtonItem to be used as the right bar button item.
 */
- (UIBarButtonItem *)rightButton
{
	if (!_rightButton)
	{
		UIImage *rightButtonImage		= [UIImage imageNamed:@"barbuttonitem_main_normal_selection_yummly"];
		
		_rightButton					= [[UIBarButtonItem alloc] initWithImage:rightButtonImage
															style:UIBarButtonItemStylePlain
														   target:self
														   action:@selector(rightButtonTapped)];
	}
	
	return _rightButton;
}

/**
 *	the scroll view encapsulating the recipe search view
 */
- (UIScrollView *)scrollView
{
	if (!_scrollView)
	{
		_scrollView						= [[UIScrollView alloc] init];
		_scrollView.backgroundColor		= [UIColor whiteColor];
		_scrollView.contentSize			= self.recipeDetailsView.bounds.size;
		_scrollView.maximumZoomScale	= 1.0f;
		_scrollView.minimumZoomScale	= 1.0f;
		
		_scrollView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_scrollView];
		[_scrollView addSubview:self.recipeDetailsView];
	}
	return _scrollView;
}

/**
 *
 *
 *	@param
 */
- (void)setRecipeID:(NSString *)recipeID
{
	_recipeID							= recipeID;
	self.recipe							= [[Recipe alloc] initWithRecipeID:_recipeID andDelegate:self];
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"scrollView"	: self.scrollView	};
}

#pragma mark - View Lifecycle

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	self.recipeDetailsView.frame		= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.recipeDetailsView.bounds.size.height);
	self.scrollView.contentSize			= self.recipeDetailsView.bounds.size;
	[self addToolbarItemsAnimated:NO];
}

@end
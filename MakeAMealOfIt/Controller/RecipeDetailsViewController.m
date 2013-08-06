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
#import "WebViewController.h"
#import "YummlyAPI.h"

#pragma mark - Recipe Details VC Private Class Extension

@interface RecipeDetailsViewController () <RecipeDelegate, RecipeDetailsViewDelegate> {}

#pragma mark - Private Properties

/**	A block to call when the recipe's attribution view controller has loaded.	*/
@property (nonatomic, copy)		AttributionDictionaryLoaded	attributionDictionaryLoaded;
/**	The object representing the recipe to be shown by this view controller.	*/
@property (nonatomic, strong)	Recipe						*recipe;
/**	The main view that will display the details of the recipe.	*/
@property (nonatomic, strong)	RecipeDetailsView			*recipeDetailsView;
/**	The ID of the recipe this view controller will show through it's views.	*/
@property (nonatomic, strong)	NSString					*recipeID;
/**	The name of the recipe being presented by this view controller.	*/
@property (nonatomic, strong)	NSString					*recipeName;
/**	The right toolbar button used to slide in the right view	*/
@property (nonatomic, strong)	UIBarButtonItem				*rightButton;
/**	The scroll view encapsulating the recipe details view.	*/
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
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
																options:kNilOptions
																metrics:nil
																  views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

#pragma mark - Convenience & Helper Methods

- (void)updateRecipeDetailsViewFrame
{
	CGRect recipeDetailsFrame;
	recipeDetailsFrame.origin			= CGPointZero;
	recipeDetailsFrame.size				= self.recipeDetailsView.intrinsicContentSize;
	self.recipeDetailsView.frame		= recipeDetailsFrame;
	self.scrollView.contentSize			= self.recipeDetailsView.bounds.size;
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
 *	@param	recipeName					The name of the recipe this view controller will show.
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

#pragma mark - RecipeDelegate Methods

/**
 *	Called when the recipe loaded it's details.
 */
- (void)recipeDictionaryHasLoaded
{	
	[self.recipeDetailsView recipeDictionaryHasLoaded];
	
	[self updateRecipeDetailsViewFrame];
	
	//	notify the right view controller that the attribution dictionary has been loaded
	if (self.attributionDictionaryLoaded)
		self.attributionDictionaryLoaded(self.recipe.attributionDictionary);
}

#pragma mark - RecipeDetailsViewDelegate Methods

/**
 *	Opens the recipe's source website with instructions and other stuff.
 */
- (void)openRecipeWebsite
{
	NSString *recipeURLString			= self.recipe.sourceDictionary[kYummlyRecipeSourceRecipeURLKey];
	NSURL *recipeURL					= [[NSURL alloc] initWithString:recipeURLString];
	WebViewController *webVC			= [[WebViewController alloc] initWithURL:recipeURL];
	[self.slideNavigationController pushCentreViewController:webVC withRightViewController:nil animated:YES];
}

/**
 *	Sent to the delegate when the sender has updated it's intrinsicContentSize.
 */
- (void)updatedIntrinsicContentSize
{
	[self updateRecipeDetailsViewFrame];
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
 *	Sent to the delegate with a block that should be called when the attribution dictionary has been loaded.
 *
 *	@param	attributionDictionaryLoaded	A block to be called with a loaded attribution dictionary.
 */
- (void)blockToCallWithAttributionDictionary:(AttributionDictionaryLoaded)attributionDictionaryLoaded
{
	if (self.recipe.attributionDictionary)
		attributionDictionaryLoaded(self.recipe.attributionDictionary);
	else
		self.attributionDictionaryLoaded= attributionDictionaryLoaded;
}

/**
 *	Instructs the centre view controller to open a URL in a web view of some sort.
 *
 *	@param	url							An NSURL to open in some sort of web view.
 *	@param	rightViewController			The new right view controller to present alongside the URL in a web view of some sort.
 */
- (void)openURL:(NSURL *)url withRightViewController:(UIViewController *)rightViewController
{
	WebViewController *webViewController= [[WebViewController alloc] initWithURL:url];
	
	[self.slideNavigationController pushCentreViewController:webViewController withRightViewController:rightViewController animated:YES];
}

#pragma mark - Setter & Getter Methods

/**
 *	The main view that will display the details of the recipe.
 *
 *	@return	An initialised view specially configured to display a recipe.
 */
- (RecipeDetailsView *)recipeDetailsView
{
	if (!_recipeDetailsView)
	{
		_recipeDetailsView				= [[RecipeDetailsView alloc] initWithRecipe:self.recipe];
		_recipeDetailsView.clipsToBounds= NO;
		_recipeDetailsView.delegate		= self;
		_recipeDetailsView.frame		= self.view.bounds;
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
 *	The scroll view encapsulating the recipe details view.
 *
 *	@return	An initialised UIScrollView holding the recipeDetailsView.
 */
- (UIScrollView *)scrollView
{
	if (!_scrollView)
	{
		_scrollView						= [[UIScrollView alloc] init];
		_scrollView.backgroundColor		= [UIColor whiteColor];
		//_scrollView.clipsToBounds		= NO;
		_scrollView.contentInset		= UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
		_scrollView.maximumZoomScale	= 1.0f;
		_scrollView.minimumZoomScale	= 1.0f;
		
		_scrollView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_scrollView];
		[_scrollView addSubview:self.recipeDetailsView];
	}
	
	return _scrollView;
}

/**
 *	The setter of the ID for the recipe to be displayed.
 *
 *	@param	recipeID					The ID of the recipe this view controller will show through it's views.
 */
- (void)setRecipeID:(NSString *)recipeID
{
	if ([_recipeID isEqualToString:recipeID])
		return;
	
	_recipeID							= recipeID;
	
	//	initialise the recipe object with the given ID
	self.recipe							= [[Recipe alloc] initWithRecipeID:_recipeID andDelegate:self];
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"scrollView"	: self.scrollView	};
}

#pragma mark - View Lifecycle

/**
 *	Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 *	@param	animated					If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateRecipeDetailsViewFrame];
	[self addToolbarItemsAnimated:NO];
}

@end
//
//  RecipeDetailsViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "FavouriteRecipesStore.h"
#import "OverlayActivityIndicator.h"
#import "RecipeDetailsViewController.h"
#import "RecipeDetailsView.h"
#import "WebViewController.h"
#import "YummlyAPI.h"

#pragma mark - Recipe Details VC Private Class Extension

@interface RecipeDetailsViewController () <RecipeDelegate, RecipeDetailsViewDelegate> {}

#pragma mark - Private Properties

/**	Used to show that the recipe image is loading.	*/
@property (nonatomic, strong)	OverlayActivityIndicator	*activityIndicatorView;
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
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.0f
														   constant:0.0f]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
														  attribute:NSLayoutAttributeCenterY
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterY
														 multiplier:1.0f
														   constant:0.0f]];
	[self.activityIndicatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
																		   attribute:NSLayoutAttributeHeight
																		   relatedBy:NSLayoutRelationEqual
																			  toItem:nil
																		   attribute:NSLayoutAttributeNotAnAttribute
																		  multiplier:1.0f
																			constant:self.activityIndicatorView.intrinsicContentSize.height]];
	[self.activityIndicatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
																		   attribute:NSLayoutAttributeWidth
																		   relatedBy:NSLayoutRelationEqual
																			  toItem:nil
																		   attribute:NSLayoutAttributeNotAnAttribute
																		  multiplier:1.0f
																			constant:self.activityIndicatorView.intrinsicContentSize.width]];
	[self.view bringSubviewToFront:self.activityIndicatorView];
}

#pragma mark - Convenience & Helper Methods



/**
 *	Updates the frame of the recipeDetailsView.
 */
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
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)initWithRecipe:(Recipe *)recipe
{
	if (self = [super init])
	{
		self.recipe						= recipe;
		self.recipe.delegate			= self;
		self.recipeName					= self.recipe.recipeName;
	}
	
	return self;
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
	if (!self.internetConnectionExists)
	{
		[[[UIAlertView alloc] initWithTitle:@"Can't Open Recipe Website"
									message:@"Due to a lack of internet connection the website for this recipe cannot be opened."
								   delegate:self
						  cancelButtonTitle:@"Understood"
						  otherButtonTitles:nil] show];
		return;
	}
	
	[self.activityIndicatorView startAnimating];
	
	NSString *recipeURLString			= self.recipe.sourceDictionary[kYummlyRecipeSourceRecipeURLKey];
	NSURL *recipeURL					= [[NSURL alloc] initWithString:recipeURLString];
	
	[self openURL:recipeURL withRightViewController:nil];
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
	if (!self.internetConnectionExists)
	{
		[[[UIAlertView alloc] initWithTitle:@"Cannot Connect to the Internet"
									message:@"Due to a possible implosion of the internet, or perhaps a loss of connection, we cannot open the web page.\nSorry for the inconvenience."
								   delegate:self
						  cancelButtonTitle:@"Understood"
						  otherButtonTitles:nil] show];
		[self.activityIndicatorView stopAnimating];
		return;
	}
	
	WebViewController *webViewController= [[WebViewController alloc] initWithURL:url];
	
	[self.slideNavigationController setControllerState:SlideNavigationSideControllerClosed
								 withCompletionHandler:
	^{
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self presentViewController:webViewController animated:YES completion:
			^{
				[self.activityIndicatorView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
			}];
		});
	}];
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The view that shows the user that the recipe image is loading.
 *
 *	@return	A UIActivityIndicatorView representing loading.
 */
- (OverlayActivityIndicator *)activityIndicatorView
{
	if (!_activityIndicatorView)
	{
		_activityIndicatorView			= [[OverlayActivityIndicator alloc] init];
		_activityIndicatorView.activityBackgroundColour	= kDarkGreyColourWithAlpha(0.5f);
		_activityIndicatorView.activityIndicatorColour	= [UIColor whiteColor];
		
		_activityIndicatorView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_activityIndicatorView];
	}
	
	return _activityIndicatorView;
}

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
		UIImage *rightButtonImage		= [UIImage imageNamed:@"barbuttonitem_main_normal_attribution_yummly"];
		
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
	
	//	if this recipe has been favourited we fetch it without contacting the server
	self.recipe							= [FavouriteRecipesStore getRecipeForRecipeID:_recipeID];
	self.recipe.delegate				= self;
	
	//	initialise the recipe object with the given ID if it has not been favourited
	if (!self.recipe)
		self.recipe						= [[Recipe alloc] initWithRecipeID:_recipeID andDelegate:self];
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"scrollView"	: self.scrollView	};
}

#pragma mark - Slide Navigation Controller Lifecycle

/**
 *	Notifies the view controller that the parent slideNavigationController has closed all side views.
 */
- (void)slideNavigationControllerDidClose
{
	self.recipeDetailsView.canShowLoading	= YES;
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
	[self addToolbarItemsAnimated:NO];
}

@end
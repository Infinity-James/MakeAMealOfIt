//
//  RecipeSearchViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "RecipeSearchView.h"
#import "RecipeSearchViewController.h"
#import "RecipesViewController.h"
#import "ToolbarLabelYummlyTheme.h"
#import "YummlyAPI.h"

#pragma mark - Recipe Search View Controller Private Class Extension

@interface RecipeSearchViewController () <RecipeSearchViewController> {}

#pragma mark - Private Properties

@property (nonatomic, strong)	UIBarButtonItem			*cupboardButton;
@property (nonatomic, strong)	UIBarButtonItem			*fridgeButton;
@property (nonatomic, strong)	RecipeSearchView		*recipeSearchView;
@property (nonatomic, strong)	UIScrollView			*scrollView;
@property (nonatomic, strong)	UIToolbar				*toolbar;
@property (nonatomic, strong)	NSDictionary			*viewsDictionary;

@end

#pragma mark - Recipe Search View Controller Implementation

@implementation RecipeSearchViewController {}

#pragma mark - Synthesis Properties

@synthesize backButton					= _backButton;
@synthesize movingViewBlock				= _movingViewBlock;

#pragma mark - Action & Selector Methods

/**
 *	called when the button in the toolbar for the left panel is tapped
 */
- (void)leftButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	
	if (!self.movingViewBlock)			return;
	
	switch (self.leftButtonTag)
	{
		case kButtonInUse:		self.movingViewBlock(MovingViewOriginalPosition);	break;
		case kButtonNotInUse:	self.movingViewBlock(MovingViewRight);				break;
		default:																	break;
	}
}

/**
 *	called when the button in the toolbar for the right panel is tapped
 */
- (void)rightButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	
	if (!self.movingViewBlock)			return;
	
	switch (self.rightButtonTag)
	{
		case kButtonInUse:		self.movingViewBlock(MovingViewOriginalPosition);	break;
		case kButtonNotInUse:	self.movingViewBlock(MovingViewLeft);				break;
		default:																	break;
	}
}

#pragma mark - Autolayout Methods

/**
 *	adds the constraints for the table view and the toolbar
 */
- (void)addConstraintsForMainView
{
	NSArray *constraints;
	
	//	add the table view to cover the whole main view except for the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(==44)][scrollView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
}

/**
 *	called when the view controller’s view needs to update its constraints
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	[self addConstraintsForMainView];
	
	[self.view bringSubviewToFront:self.toolbar];
}

#pragma mark - Autorotation

/**
 *	returns a boolean value indicating whether rotation methods are forwarded to child view controllers
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	returns whether the view controller’s contents should auto rotate
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

#pragma mark - CentreViewControllerProtocol Methods

/**
 *	returns the left button tag
 */
- (NSUInteger)leftButtonTag
{
	return self.cupboardButton.tag;
}

/**
 *	returns right button tag
 */
- (NSUInteger)rightButtonTag
{
	return self.fridgeButton.tag;
}

/**
 *	sets the tag of the button to the left of the toolbar
 */
- (void)setLeftButtonTag:(NSUInteger)tag
{
	self.cupboardButton.tag				= tag;
}

/**
 *	sets the tag of the button to the right of the toolbar
 */
- (void)setRightButtonTag:(NSUInteger)tag
{
	self.fridgeButton.tag				= tag;
}

#pragma mark - Convenience & Helper Methods

#pragma mark - Initialisation

/**
 *	adds toolbar items to our toolbar
 */
- (void)addToolbarItems
{
	self.cupboardButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_hamburger"]
															   style:UIBarButtonItemStyleBordered target:self action:@selector(leftButtonTapped)];
	
	UIBarButtonItem *flexibleSpace		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UILabel *title						= [[UILabel alloc] init];
	title.backgroundColor				= [UIColor clearColor];
	title.text							= @"Make a Meal Of It";
	title.textAlignment					= NSTextAlignmentCenter;
	[ThemeManager customiseLabel:title withTheme:[[ToolbarLabelYummlyTheme alloc] init]];
	[title sizeToFit];
	UIBarButtonItem *titleItem			= [[UIBarButtonItem alloc] initWithCustomView:title];
	
	self.fridgeButton					= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonitem_allergies"]
															 style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonTapped)];
	
	self.toolbar.items					= @[self.cupboardButton, flexibleSpace, titleItem, flexibleSpace, self.fridgeButton];
}

/**
 *	called to initialise a class instance
 */
- (id)init
{
	if (self = [super init])
	{
		
	}
	
	return self;
}

#pragma mark - RecipeSerachViewController Methods

/**
 *	called when a view controller was added to recipe search view
 *
 *	@param	viewController				the view controller which was added to the view
 */
- (void)addedViewController:(UIViewController *)viewController
{
	[self addChildViewController:viewController];
	[viewController didMoveToParentViewController:self];
}

/**
 *
 *
 *	@param
 */
- (void)searchExecutedForResults:(NSDictionary *)results
{
	RecipesViewController *recipesVC	= [[RecipesViewController alloc] init];
	recipesVC.recipes					= results[kYummlyMatchesArrayKey];
	[appDelegate.slideOutVC showCentreViewController:recipesVC withRightViewController:[[RecipesViewController alloc] init]];
	
}

#pragma mark - Setter & Getter Methods

/**
 *	this is the main view that holds all the stuff
 */
- (RecipeSearchView *)recipeSearchView
{
	if (!_recipeSearchView)
	{
		_recipeSearchView				= [[RecipeSearchView alloc] init];
		//_recipeSearchView.translatesAutoresizingMaskIntoConstraints		= NO;
		_recipeSearchView.frame			= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 500.0f);
		_recipeSearchView.delegate		= self;
	}
	
	return _recipeSearchView;
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
		_scrollView.contentSize			= self.recipeSearchView.bounds.size;
		_scrollView.maximumZoomScale	= 1.0f;
		_scrollView.minimumZoomScale	= 1.0f;
		_scrollView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_scrollView];
		[_scrollView addSubview:self.recipeSearchView];
	}
	return _scrollView;
}

/**
 *	a toolbar to keep at the top of the view
 */
- (UIToolbar *)toolbar
{
	if (!_toolbar)
	{
		_toolbar						= [[UIToolbar alloc] init];
		_toolbar.clipsToBounds			= NO;
		[ThemeManager customiseToolbar:_toolbar withTheme:nil];
		_toolbar.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_toolbar];
	}
	
	return _toolbar;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"recipeSearchView"	: self.recipeSearchView,
				@"scrollView"		: self.scrollView,
				@"toolbar"			: self.toolbar};
}

#pragma mark - View Lifecycle

/**
 *	sent to the view controller when the app receives a memory warning
 */
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self addToolbarItems];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated					whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
}

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
	self.recipeSearchView.frame		= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.recipeSearchView.bounds.size.height);
	[self.recipeSearchView setNeedsUpdateConstraints];
}


@end
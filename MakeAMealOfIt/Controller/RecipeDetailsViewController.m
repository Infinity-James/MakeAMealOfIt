//
//  RecipeDetailsViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "RecipeDetailsView.h"
#import "YummlyAPI.h"

#pragma mark - Recipe Details VC Private Class Extension

@interface RecipeDetailsViewController () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	RecipeDetailsView		*recipeDetailsView;
@property (nonatomic, strong)	NSString				*recipeID;
@property (nonatomic, strong)	UIScrollView			*scrollView;

@end

#pragma mark - Recipe Details VC Implementation

@implementation RecipeDetailsViewController {}

#pragma mark - Autolayout Methods

/**
 *	called when the view controller’s view needs to update its constraints
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	NSArray *constraints;
	
	//	add the collection view to cover the whole main view except for the toolbar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:kNilOptions metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	CGFloat toolbarHeight				= self.toolbarHeight;
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(height)][scrollView]|" options:kNilOptions metrics:@{@"height": @(toolbarHeight)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
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

/**
 *	sent to the view controller just before the user interface begins rotating
 *
 *	@param	toInterfaceOrientation		new orientation for the user interface
 *	@param	duration					duration of the pending rotation, measured in seconds
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
}

#pragma mark - CentreViewControllerProtocol Methods

/**
 *	returns the left button tag
 */
- (NSUInteger)leftButtonTag
{
	return self.leftButton.tag;
}

/**
 *	returns right button tag
 */
- (NSUInteger)rightButtonTag
{
	return self.rightButton.tag;
}

/**
 *	sets the tag of the button to the left of the toolbar
 */
- (void)setLeftButtonTag:(NSUInteger)tag
{
	self.leftButton.tag					= tag;
}

/**
 *	sets the tag of the button to the right of the toolbar
 */
- (void)setRightButtonTag:(NSUInteger)tag
{
	self.rightButton.tag				= tag;
}

#pragma mark - Initialisation

/**
 *	adds toolbar items to our toolbar
 */
- (void)addToolbarItemsAnimated:(BOOL)animate
{
	if (self.backButton)
		self.leftButton					= self.backButton;
	else
		self.leftButton					= [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStyleBordered target:self action:@selector(leftButtonTapped)];
	
	UIBarButtonItem *flexibleSpace		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	self.rightButton					= [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonTapped)];
	
	[self.toolbar setItems:@[self.leftButton, flexibleSpace, self.rightButton] animated:animate];
}

/**
 *	called to initialise a class instance
 */
- (instancetype)initWithRecipeID:(NSString *)recipeID
{
	if (self = [super init])
	{
		self.recipeID					= recipeID;
	}
	
	return self;
}

#pragma mark - Setter & Getter Methods

/**
 *
 */
- (RecipeDetailsView *)recipeDetailsView
{
	if (!_recipeDetailsView)
	{
		_recipeDetailsView				= [[RecipeDetailsView alloc] initWithRecipe:[[Recipe alloc] initWithRecipeID:self.recipeID]];
		_recipeDetailsView.frame		= CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 500.0f);
	}
	
	return _recipeDetailsView;
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
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"scrollView"	: self.scrollView,
				@"toolbar"		: self.toolbar};
}

@end
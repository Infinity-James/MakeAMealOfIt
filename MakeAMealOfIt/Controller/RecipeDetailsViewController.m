//
//  RecipeDetailsViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 28/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "RecipeDetailsView.h"

#pragma mark - Recipe Details VC Private Class Extension

@interface RecipeDetailsViewController () {}

#pragma mark - Private Properties

@property (nonatomic, strong)	RecipeDetailsView		*recipeDetailsView;
@property (nonatomic, strong)	UIScrollView			*scrollView;
@property (nonatomic, strong)	UIToolbar				*toolbar;
@property (nonatomic, strong)	NSDictionary			*viewsDictionary;


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
	//[self.pageViewController.presentedViewController.view performSelector:@selector(setNeedsUpdateConstraints)];
}

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 */
- (instancetype)init
{
	if (self = [super init])
	{
		
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
		_recipeDetailsView				= [[RecipeDetailsView alloc] initWithRecipeDictionary:nil];
		CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 500.0f);
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
	return @{	@"scrollView"	: self.scrollView};
}

@end
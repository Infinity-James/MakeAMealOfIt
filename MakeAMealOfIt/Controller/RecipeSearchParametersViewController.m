//
//  RecipeSearchParametersViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 20/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ParameterPageViewController.h"
#import "RecipeSearchParametersViewController.h"

#pragma mark - Constants & Static Variables

static NSString *const kOptionsDietKey		= @"Diet";
static NSString *const kOptionsHolidayKey	= @"Holiday";
static NSString *const kOptionsIngredientKey= @"Ingredient";

#pragma mark - Recipe Search Parameters VC Private Class Extension

@interface RecipeSearchParametersViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {}

#pragma mark - Private Properties

@property (nonatomic, assign)	NSUInteger				currentPageIndex;
@property (nonatomic, strong)	NSDictionary			*optionsDictionary;
@property (nonatomic, strong)	UIPageViewController	*pageViewController;
@property (nonatomic, strong)	NSDictionary			*viewsDictionary;

@end

#pragma mark - Recipe Search Parameters VC Implementation

@implementation RecipeSearchParametersViewController {}

#pragma mark - Autolayout Methods

/**
 *	called when the view controller’s view needs to update its constraints
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	NSArray *constraints				= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageView]|" options:kNilOptions
																	  metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageView]|" options:kNilOptions
																metrics:nil views:self.viewsDictionary];
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
	//[self.pageViewController.presentedViewController.view performSelector:@selector(setNeedsUpdateConstraints)];
}

#pragma mark - Convenience & Helper Methods

/**
 *
 */
- (NSArray *)keysAsArray
{
	return [self.optionsDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *keyA, NSString *keyB)
	{
		if (((NSArray *)self.optionsDictionary[keyA]).count > ((NSArray *)self.optionsDictionary[keyB]).count)
			return NSOrderedDescending;
		else if (((NSArray *)self.optionsDictionary[keyA]).count < ((NSArray *)self.optionsDictionary[keyB]).count)
			return NSOrderedAscending;
		
		return NSOrderedSame;
	}];
}

/**
 *	returns the options dictionary's values as a sorted array
 */
- (NSArray *)optionsAsArray
{
	return [self.optionsDictionary.allValues sortedArrayUsingComparator:^NSComparisonResult(NSArray *arrayA, NSArray *arrayB)
	{
		if (arrayA.count > arrayB.count)
			return NSOrderedDescending;
		
		else if (arrayA.count < arrayB.count)
			return NSOrderedAscending;

		return NSOrderedSame;
	}];
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
 *	this options dictionary defines the options aviable in each page
 */
- (NSDictionary *)optionsDictionary
{
	if (!_optionsDictionary)
	{
		_optionsDictionary				= @{kOptionsDietKey			: @[@"Option A", @"Option B", @"Option C", @"Option D",
																		@"Option E", @"Option F", @"Option G", @"Option H", @"Option I"],
											kOptionsHolidayKey		: @[@"Option A", @"Option B", @"Option C", @"Option D",
																		@"Option E", @"Option F", @"Option G", @"Option H", @"Option I"],
											kOptionsIngredientKey	: @[@"Option A", @"Option B", @"Option C", @"Option D",
																		@"Option E", @"Option F", @"Option G", @"Option H", @"Option I"]};
	}
	
	return _optionsDictionary;
}

/**
 *	this is the page view controller that display the spinning wheels
 */
- (UIPageViewController *)pageViewController
{
	if (!_pageViewController)
	{
		_pageViewController				= [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
																 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
																			   options:@{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMin)}];
		_pageViewController.view.translatesAutoresizingMaskIntoConstraints	= NO;
		_pageViewController.dataSource	= self;
		_pageViewController.delegate	= self;
		ParameterPageViewController *firstPage		= [[ParameterPageViewController alloc] init];
		self.currentPageIndex			= 0;
		firstPage.index					= self.currentPageIndex;
		firstPage.optionLabel.text		= [self keysAsArray][firstPage.index];
		firstPage.options				= [self optionsAsArray][self.currentPageIndex];
		[_pageViewController setViewControllers:@[firstPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
		
		self.view.gestureRecognizers	= _pageViewController.gestureRecognizers;
		
		[self.view addSubview:_pageViewController.view];
		[self addChildViewController:_pageViewController];
		[_pageViewController didMoveToParentViewController:self];
		
	}
	
	return _pageViewController;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"pageView"	: self.pageViewController.view};
}

#pragma mark - UIPageViewControllerDataSource Methods

/**
 *	returns the view controller after the given view controller
 *
 *	@param	pageViewController			page view controller
 *	@param	viewController				view controller that the user navigated away from
 */
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	   viewControllerAfterViewController:(UIViewController *)viewController
{
	ParameterPageViewController *currentPage	= (ParameterPageViewController *)viewController;
	
	//	if we are on the last page, return nil
	if (currentPage.index == self.optionsDictionary.count - 1)
		return nil;
	
	//	create the view controller to return
	ParameterPageViewController *nextPage	= [[ParameterPageViewController alloc] init];
	self.currentPageIndex					= currentPage.index + 1;
	nextPage.index							= self.currentPageIndex;
	nextPage.optionLabel.text				= [self keysAsArray][self.currentPageIndex];
	nextPage.options						= [self optionsAsArray][self.currentPageIndex];
	
	return nextPage;
}

/**
 *	returns the view controller before the given view controller
 *
 *	@param	pageViewController			page view controller
 *	@param	viewController				view controller that the user navigated away from
 */
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	  viewControllerBeforeViewController:(UIViewController *)viewController
{
	ParameterPageViewController *currentPage	= (ParameterPageViewController *)viewController;
	
	//	if the page we are on at the moment is the first page, then there is no previous controller
	if (currentPage.index == 0)
		return nil;
	
	//	create the view controller to return
	ParameterPageViewController *previousPage	= [[ParameterPageViewController alloc] init];
	self.currentPageIndex						= currentPage.index - 1;
	previousPage.index							= self.currentPageIndex;
	previousPage.optionLabel.text				= [self keysAsArray][self.currentPageIndex];
	previousPage.options						= [self optionsAsArray][self.currentPageIndex];
	
	return previousPage;
}

/**
 *	returns the number of items to be reflected in the page indicator
 *
 *	@param pageViewController			page view controller
 */
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
	return self.optionsDictionary.count;
}

/**
 *	returns the index of the selected item to be reflected in the page indicator
 *
 *	@param pageViewController			page view controller
 */
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
	return self.currentPageIndex;
}

#pragma mark - View Lifecycle

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
	//[self.pageViewController.presentedViewController.view performSelector:@selector(setNeedsUpdateConstraints)];
}

@end
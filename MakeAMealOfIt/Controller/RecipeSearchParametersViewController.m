//
//  RecipeSearchParametersViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 20/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ParameterPageViewController.h"
#import "RecipeSearchParametersViewController.h"
#import "YummlyMetadata.h"

#pragma mark - Recipe Search Parameters VC Private Class Extension

@interface RecipeSearchParametersViewController () <ParameterPageDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate> {}

#pragma mark - Private Properties

/**	A dictionary defining the options aviable in each page.	*/
@property (nonatomic, strong)	NSDictionary			*optionsDictionary;
/**	A page view controller that displays the spinning wheels.	*/
@property (nonatomic, strong)	UIPageViewController	*pageViewController;

@end

#pragma mark - Recipe Search Parameters VC Implementation

@implementation RecipeSearchParametersViewController {}

#pragma mark - Autolayout Methods

/**
 *	Called when the view controller’s view needs to update its constraints.
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

#pragma mark - Convenience & Helper Methods

/**
 *	Convenient way to get the keys of the options dictionary as an array.
 *
 *	@return	A sorted array of the keys in the options dictionary.
 */
- (NSArray *)keysAsArray
{
	return [self.optionsDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *keyA, NSString *keyB)
	{
		return [keyA compare:keyB];
	}];
}

#pragma mark - Initialisation

/**
 *	This method gets all of the metadata.
 */
- (void)getAllOptions
{
	dispatch_async(dispatch_queue_create("Metadata Fetcher", NULL),
	^{
		//	we get the yummly metadata and remove the ingredients because that is displayed elsewhere
		NSMutableDictionary *allMetadata= [[YummlyMetadata allMetadata] mutableCopy];
		[allMetadata removeObjectForKey:kYummlyMetadataIngredients];
		self.optionsDictionary			= allMetadata;
		//	nil out the page view controller so that it is reload when we update the view
		self.pageViewController			= nil;
		[self.view performSelectorOnMainThread:@selector(setNeedsUpdateConstraints) withObject:nil waitUntilDone:NO];
	});
}

#pragma mark - ParameterPageDelegate

/**
 *	Sent to the delegate when a parameter has been selected in some fashion.
 *
 *	@param	parameterPageVC				The page calling this method.
 *	@param	parameterIndex				The index of the parameter that has been selected.
 *	@param	included					Whether the selected parameter is to be included or excluded.
 */
- (void)parameterPageViewController:(ParameterPageViewController *)parameterPageVC
		   selectedParameterAtIndex:(NSUInteger)parameterIndex
						   included:(BOOL)included
{
	NSString *choice					= self.optionsDictionary[[self keysAsArray][parameterPageVC.index]][parameterIndex];
	NSLog(@"CHOICE: %@", choice);
}

#pragma mark - Setter & Getter Methods

/**
 *	This options dictionary defines the options aviable in each page.
 *
 *	@return	A dictionary of all of the options to be displayed to the user.
 */
- (NSDictionary *)optionsDictionary
{
	//	use lazy instantiation
	if (!_optionsDictionary)
	{
		_optionsDictionary				= @{};
	}
	
	return _optionsDictionary;
}

/**
 *	This is the page view controller that displays the spinning wheels.
 *
 *	@param	A fully set up page view controller for use in displaying options.
 */
- (UIPageViewController *)pageViewController
{
	if (!_pageViewController)
	{
	
		_pageViewController				= [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
																 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
																			   options:@{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMin)}];
		if (self.optionsDictionary.count > 0)
		{
			_pageViewController.dataSource			= self;
			_pageViewController.delegate			= self;
			ParameterPageViewController *firstPage	= [[ParameterPageViewController alloc] init];
			firstPage.delegate						= self;
			firstPage.index							= 0;
			firstPage.optionCategoryTitle			= [[self keysAsArray][firstPage.index] capitalizedString];
			firstPage.options						= self.optionsDictionary[[self keysAsArray][firstPage.index]];
			[_pageViewController setViewControllers:@[firstPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
		}
		
		self.view.gestureRecognizers	= _pageViewController.gestureRecognizers;
		
		_pageViewController.view.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_pageViewController.view];
		[self addChildViewController:_pageViewController];
		[_pageViewController didMoveToParentViewController:self];
	}
	return _pageViewController;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"pageView"	: self.pageViewController.view};
}

#pragma mark - UIPageViewControllerDataSource Methods

/**
 *	Returns the view controller after the given view controller.
 *
 *	@param	pageViewController			The page view controller.
 *	@param	viewController				The view controller that the user navigated away from.
 *
 *	@return	The view controller after the given view controller, or nil to indicate that there is no next view controller.
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
	nextPage.delegate						= self;
	nextPage.index							= currentPage.index + 1;
	nextPage.optionCategoryTitle			= [[self keysAsArray][nextPage.index] capitalizedString];
	nextPage.options						= self.optionsDictionary[[self keysAsArray][nextPage.index]];
	
	return nextPage;
}

/**
 *	Returns the view controller before the given view controller.
 *
 *	@param	pageViewController			The page view controller.
 *	@param	viewController				The view controller that the user navigated away from.
 *
 *	@return	The view controller before the given view controller, or nil to indicate that there is no previous view controller.
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
	previousPage.delegate						= self;
	previousPage.index							= currentPage.index - 1;
	previousPage.optionCategoryTitle			= [[self keysAsArray][previousPage.index] capitalizedString];
	previousPage.options						= self.optionsDictionary[[self keysAsArray][previousPage.index]];
	
	return previousPage;
}

/**
 *	Returns the number of items to be reflected in the page indicator.
 *
 *	@param pageViewController			The page view controller.
 *
 *	@return	The number of items to be reflected in the page indicator.
 */
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
	return self.optionsDictionary.count;
}

/**
 *	Returns the index of the selected item to be reflected in the page indicator.
 *
 *	@param pageViewController			The page view controller.
 *
 *	@return	The index of the selected item to be reflected in the page indicator.
 */
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
	if ([pageViewController isKindOfClass:[ParameterPageViewController class]])
		return ((ParameterPageViewController *)pageViewController).index;
	else
		return 0;
}

#pragma mark - View Lifecycle

/**
 *	Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
		[self getAllOptions];
}

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
}

@end
//
//  RecipeSearchViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "BiggerButton.h"
#import "FavouriteRecipesViewController.h"
#import "MakeAMealOfItIntroduction.h"
#import "OverlayActivityIndicator.h"
#import "RecipeSearchHelpView.h"
#import "RecipeSearchView.h"
#import "RecipeSearchViewController.h"
#import "RecipesViewController.h"
#import "YummlyAttributionViewController.h"
#import "YummlySearchResult.h"

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier		= @"ChosenIngredientsCellIdentifier";
static NSString *const kHeaderIdentifier	= @"ChosenIngredientsHeaderIdentifier";

enum SectionIndex
{
	kSectionExcludedIndex		= 0,
	kSectionIncludedIndex		= 1
};

#pragma mark - Recipe Search View Controller Private Class Extension

@interface RecipeSearchViewController () <RecipeSearchViewController, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	Used to show that the recipe image is loading.	*/
@property (nonatomic, strong)	OverlayActivityIndicator	*activityIndicatorView;
/**	An NSLayout constraint with the cues centred.	*/
@property (nonatomic, strong)	NSLayoutConstraint			*centreCueConstraint;
/**	A button that allows the user to reset the entire search.	*/
@property (nonatomic, strong)	UIButton					*clearSearchButton;
/**	The image to be used for the slide cues.	*/
@property (nonatomic, strong)	UIImage						*cueImage;
/**	Allows the user to open their list of favourites.	*/
@property (nonatomic, strong)	BiggerButton				*favouritesButton;
/**	A view configured to display helpful text to the user.	*/
@property (nonatomic, strong)	RecipeSearchHelpView		*helpView;
/**	Whether or not the table view should simply be reloaded, or if NO it can be updated in an animated fashion.	*/
@property (nonatomic, assign)	BOOL						justReload;
/**	The left toolbar button used to slide in the left view.	*/
@property (nonatomic, strong)	UIBarButtonItem				*leftButton;
/**	A UITapGestureRecogniser that calls acts as though the user finished editing the search bar.	*/
@property (nonatomic, strong)	UITapGestureRecognizer		*resignGestureRecogniser;
/**	The right toolbar button used to slide in the right view	*/
@property (nonatomic, strong)	UIBarButtonItem				*rightButton;
/**	The index path of the currently selected UITableViewCell.	*/
@property (nonatomic, strong)	NSIndexPath					*selectedCellIndexPath;
/**	A dictionary of ingredients to be either included or excluded.	*/
@property (nonatomic, strong)	NSMutableDictionary			*selectedIngredients;
/**	Whether or not to shift the cues up or centre them.	*/
@property (nonatomic, assign)	BOOL						shiftCuesUp;
/**	An NSLayout constraint with the cues shifted up.	*/
@property (nonatomic, strong)	NSArray						*shiftedCueConstraints;
/**	An image that helps the user realise that they can slide to the left.	*/
@property (nonatomic, strong)	UIImageView					*slideCueLeft;
/**	An image that helps the user realise that they can slide to the right.	*/
@property (nonatomic, strong)	UIImageView					*slideCueRight;
/**	The table view representing the included or excluded ingredients for the recipe search.	*/
@property (nonatomic, strong)	UITableView					*tableView;
/**	A block to call when any left controller sata has been modified in this view controller.	*/
@property (nonatomic, copy)		LeftControllerDataModified	modifiedIngredients;
/**	This is the main view that allows the user to search.	*/
@property (nonatomic, strong)	RecipeSearchView			*recipeSearchView;
/**	A button that allows the user to see the tutorial again.	*/
@property (nonatomic, strong)	BiggerButton					*tutorialButton;

@end

#pragma mark - Recipe Search View Controller Implementation

@implementation RecipeSearchViewController {}

#pragma mark - Action & Selector Methods

/**
 *	The user has tapped the button to view their favourite recipes.Á
 */
- (void)favouritesTapped
{
	if (!self.currentlyCentre || self.slideNavigationController.controllerState != SlideNavigationSideControllerClosed)
		return;
	
	self.favouritesButton.enabled				= NO;
	FavouriteRecipesViewController *favourites	= [[FavouriteRecipesViewController alloc] init];
	[self.slideNavigationController pushCentreViewController:favourites withRightViewController:nil animated:YES];
}

/**
 *	Called when the button in the toolbar for the left panel is tapped.
 */
- (void)leftButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	if (self.slideNavigationController.controllerState == SlideNavigationSideControllerClosed)
		[self.slideNavigationController setControllerState:SlideNavigationSideControllerLeftOpen withCompletionHandler:nil];
}

/**
 *	User has selected the option to reset the search.
 */
- (void)resetSearchTapped
{
	if (![self.slideNavigationController centreViewIsActive])
		return;
	
	//	we make sure that they meant to do this
	[[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Reset Entire Search?", @"reset the search parameters")
								 delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel reset")
				   destructiveButtonTitle:NSLocalizedString(@"Reset Search", @"reset the search")
						otherButtonTitles:nil] showFromRect:self.clearSearchButton.frame inView:self.view animated:YES];
}

/**
 *	Called when the button in the toolbar for the right panel is tapped.
 */
- (void)rightButtonTapped
{
	[self.recipeSearchView resignFirstResponder];
	if (self.slideNavigationController.controllerState == SlideNavigationSideControllerClosed)
		[self.slideNavigationController setControllerState:SlideNavigationSideControllerRightOpen withCompletionHandler:nil];
}

/**
 *	The user wishes to see the tutorial again.
 */
- (void)tutorialTapped
{
	[MakeAMealOfItIntroduction showIntroductionViewWithFrame:self.view.superview.bounds inView:self.view.superview];
}

/**
 *	Called when the global Yummly Request object has been reset.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenReset:(NSNotification *)notification
{
	dispatch_async(dispatch_queue_create("Ingredients Clearer", NULL),
	^{
		NSUInteger excludedCount			= ((NSArray *)self.selectedIngredients[kExcludedSelections]).count;
		NSUInteger includedCount			= ((NSArray *)self.selectedIngredients[kIncludedSelections]).count;
					   
		NSMutableArray *indexPaths			= [[NSMutableArray alloc] initWithCapacity:excludedCount + includedCount];
					   
		for (NSUInteger index = 0; index < excludedCount; index++)
			[indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:kSectionExcludedIndex]];
		for (NSUInteger index = 0; index < includedCount; index++)
			[indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:kSectionIncludedIndex]];
					   
		self.selectedIngredients			= nil;
					   
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
			//	we do this to reload the section headers
			NSTimeInterval delayInSeconds	= 0.3f;
			dispatch_time_t delayDispatch	= dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
										  
			dispatch_after(delayDispatch, dispatch_get_main_queue(), ^(void)
			{
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
							  withRowAnimation:UITableViewRowAnimationFade];
				self.shiftCuesUp				= NO;
			});
		});
	});
}

/**
 *	Called when the global Yummly Request object has been altered.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenChanged:(NSNotification *)notification
{
	self.clearSearchButton.enabled		= YES;
}

/**
 *	Called when the global Yummly Request object is effectively nil.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestIsEmpty:(NSNotification *)notification
{
	self.clearSearchButton.enabled		= NO;
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
	
	CGFloat barHeight					= self.slideNavigationController.slideNavigationBar.frame.size.height + 10.0f;
	CGSize helpViewSize					= self.helpView.intrinsicContentSize;
	CGSize activityIndicatorSize		= self.activityIndicatorView.intrinsicContentSize;
	
	//	add the table view to cover the whole main view except for the toolbar
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[recipeSearchView]|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[clearSearchButton]-|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(height)-[recipeSearchView(==150)]-[tableView]"
																	  options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
																	  metrics:@{@"height": @(barHeight)}
																		views:self.viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[helpView(height)]"
																	  options:kNilOptions
																	  metrics:@{@"height": @(helpViewSize.height)}
																		views:self.viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableView]-[clearSearchButton]-|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tutorialButton]-|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tutorialButton]-(32)-[favourites]"
																	  options:NSLayoutFormatAlignAllCenterY
																	  metrics:nil
																		views:self.viewsDictionary]];
	[self.favouritesButton addConstraint:[NSLayoutConstraint constraintWithItem:self.favouritesButton
																	  attribute:NSLayoutAttributeHeight
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	  attribute:NSLayoutAttributeNotAnAttribute
																	 multiplier:1.0f
																	   constant:16.0f]];
	[self.favouritesButton addConstraint:[NSLayoutConstraint constraintWithItem:self.favouritesButton
																	  attribute:NSLayoutAttributeWidth
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:self.favouritesButton
																	  attribute:NSLayoutAttributeHeight
																	 multiplier:1.0f
																	   constant:0.0f]];
	
	if (self.shiftCuesUp)
		[self.view addConstraints:self.shiftedCueConstraints];
	else
		[self.view addConstraint:self.centreCueConstraint];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.slideCueLeft
														  attribute:NSLayoutAttributeCenterY
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.slideCueRight
														  attribute:NSLayoutAttributeCenterY
														 multiplier:1.0f
														   constant:0.0f]];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.helpView
														  attribute:NSLayoutAttributeCenterY
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterY
														 multiplier:1.0f
														   constant:0.0f]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cueLeft]-[helpView]-[cueRight]-|"
																	  options:kNilOptions
																	  metrics:nil
																		views:self.viewsDictionary]];
	
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
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[activityView(==height)]"
																	  options:kNilOptions
																	  metrics:@{@"height": @(activityIndicatorSize.height)}
																		views:self.viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[activityView(==width)]"
																	  options:kNilOptions
																	  metrics:@{@"width": @(activityIndicatorSize.width)}
																		views:self.viewsDictionary]];
	
	[self.view bringSubviewToFront:self.helpView];
	[self.view bringSubviewToFront:self.slideCueLeft];
	[self.view bringSubviewToFront:self.slideCueRight];
	[self.view bringSubviewToFront:self.activityIndicatorView];
}

#pragma mark - Convenience & Helper Methods

/**
 *	Flips the slide cues to face the opposite direction.
 */
- (void)flipSlideCues
{
	[UIView animateWithDuration:0.2f animations:
	 ^{
		 self.slideCueLeft.transform		= CGAffineTransformRotate(self.slideCueLeft.transform, M_PI);
		 self.slideCueRight.transform	= CGAffineTransformRotate(self.slideCueRight.transform, M_PI);
	 }];
}

/**
 *	Conveniently returns the correcr array for the given section.
 *
 *	@param	section						The section of a table or collection view requesting an array.
 *
 *	@return	An array of ingredients relevant to the section.
 */
- (NSArray *)ingredientsArrayForSection:(NSUInteger)section
{
	if (section == kSectionExcludedIndex)
		return self.selectedIngredients[kExcludedSelections];
	else if (section == kSectionIncludedIndex)
		return self.selectedIngredients[kIncludedSelections];
	return nil;
}

/**
 *	Registers for any notifications that thic view controller wants to observe.
 */
- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(yummlyRequestHasBeenReset:)
												 name:kNotificationYummlyRequestReset
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(yummlyRequestHasBeenChanged:)
												 name:kNotificationYummlyRequestChanged
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(yummlyRequestIsEmpty:)
												 name:kNotificationYummlyRequestEmpty
											   object:nil];
}

#pragma mark - Initialisation

/**
 *	Adds toolbar items to our toolbar.
 *
 *	@param	animated					Whether or not the toolbar items should be an animated fashion.
 */
- (void)addToolbarItemsAnimated:(BOOL)animated
{
	[self.slideNavigationItem setTitle:NSLocalizedString(@"Make A Meal Of It", @"Make A Meal Of It") animated:YES];
	[self.slideNavigationItem setLeftBarButtonItem:self.leftButton animated:YES];
	[self.slideNavigationItem setRightBarButtonItem:self.rightButton animated:YES];
	
}

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
		[self registerForNotifications];
	}
	
	return self;
}

#pragma mark - Left Controller Delegate Methods

/**
 *	A block sent by the delegate to be executed when data has been modified.
 *
 *	@param	dataModifiedBlack			Intended to be executed with any modified data.
 */
- (void)blockToExecuteWhenDataModified:(LeftControllerDataModified)dataModifiedBlock
{
	//	store the block to execute it later
	self.modifiedIngredients			= dataModifiedBlock;
}

/**
 *	Sent to the delegate when a user has updated any selections in the left view controller.
 *
 *	@param	leftViewController			The left view controller sending this message.
 *	@param	selections					The selections dictionary with all of the selections in the table view.
 */
- (void)leftController:(UIViewController *)leftViewController
 updatedWithSelections:(NSDictionary *)selections
{
	//	get the newly added and removed selections
	NSDictionary *addedSelections				= selections[kAddedSelections];
	NSDictionary *removedSelections				= selections[kRemovedSelections];
	
	//	get the currently selected included and excluded ingredient dictionaries in arrays
	__block NSMutableArray *excludedIngredients	= [self.selectedIngredients[kExcludedSelections] mutableCopy];
	__block NSMutableArray *includedIngredients	= [self.selectedIngredients[kIncludedSelections] mutableCopy];
	
	//	asynchronously add the selections to the yummly request and update our array for the table view
	dispatch_sync(dispatch_queue_create("Selected Ingredients Updater", NULL),
	^{
		//	create variables to know what index paths to reload
		NSMutableArray *indexPathsToInsert	= [[NSMutableArray alloc] init];
		NSMutableArray *indexPathsToDelete	= [[NSMutableArray alloc] init];
	  
		if (addedSelections)
		{
			//	get the included and excluded selections that have been added
			NSArray *addedExcluded		= addedSelections[kExcludedSelections];
			NSArray *addedIncluded		= addedSelections[kIncludedSelections];
			
			//	add the newly added ingredient dictionaries to the currently selected ones
			[excludedIngredients addObjectsFromArray:addedExcluded];
			[includedIngredients addObjectsFromArray:addedIncluded];
			
			//	for every newly added excluded ingredient dictionary we update the yummly request and store it to be inserted into the table view
			for (NSDictionary *ingredientDictionary in addedExcluded)
			{
				[indexPathsToInsert addObject:[NSIndexPath indexPathForRow:[excludedIngredients indexOfObject:ingredientDictionary]
																 inSection:kSectionExcludedIndex]];
				[appDelegate.yummlyRequest addExcludedIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
			}
		  
			//	for every newly added included ingredient dictionary we update the yummly request and store it to be inserted into the table view
			for (NSDictionary *ingredientDictionary in addedIncluded)
			{
				[indexPathsToInsert addObject:[NSIndexPath indexPathForRow:[includedIngredients indexOfObject:ingredientDictionary]
																 inSection:kSectionIncludedIndex]];
			  
				[appDelegate.yummlyRequest addDesiredIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
			}
		}
	  
		if (removedSelections)
		{
			//	get the included and excluded selections that have been deleted
			NSArray *removedExcluded	= removedSelections[kExcludedSelections];
			NSArray *removedIncluded	= removedSelections[kIncludedSelections];
		  
			//	for the removed excluded ingredient dictionaries we update the yummly request and store it to be deleted from the table view
			for (NSDictionary *ingredientDictionary in removedExcluded)
			{
				[indexPathsToDelete addObject:[NSIndexPath indexPathForRow:[excludedIngredients indexOfObject:ingredientDictionary]
																 inSection:kSectionExcludedIndex]];
				[appDelegate.yummlyRequest removeExcludedIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
			}
		  
			//	for the removed included ingredient dictionaries we update the yummly request and store it to be deleted from the table view
			for (NSDictionary *ingredientDictionary in removedIncluded)
			{
				[indexPathsToDelete addObject:[NSIndexPath indexPathForRow:[includedIngredients indexOfObject:ingredientDictionary]
																 inSection:kSectionIncludedIndex]];
				[appDelegate.yummlyRequest removeDesiredIngredient:ingredientDictionary[kYummlyMetadataDescriptionKey]];
			}
		  
			//	remove the deleted ingredient dictionaries from our currently selected ones now that we know where they were in table view
			[excludedIngredients removeObjectsInArray:removedExcluded];
			[includedIngredients removeObjectsInArray:removedIncluded];
		}
	  
		//	store the newly updated ingredient dictionaries for both included and excluded
		self.selectedIngredients[kExcludedSelections]	= excludedIngredients;
		self.selectedIngredients[kIncludedSelections]	= includedIngredients;
	  
		NSDictionary *lastSelectedIngredients				= [self.selectedIngredients copy];
	  
		//	update the table view on the main thread
		dispatch_async(dispatch_get_main_queue(),
		^{
			if (excludedIngredients.count > 0 || includedIngredients.count > 0)
			{
				self.shiftCuesUp						= YES;
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setShiftCuesUp:) object:NO];
			}
			else
				[self performSelector:@selector(setShiftCuesUp:) withObject:NO afterDelay:0.5f];
						 
			//	if the index path updates are still accurate we update the table view in an animated fashion
			if ([lastSelectedIngredients isEqualToDictionary:self.selectedIngredients] && !self.justReload)
			{
				[self.tableView beginUpdates];
				if (indexPathsToDelete.count > 0)
					[self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationLeft];
				if (indexPathsToInsert.count > 0)
					[self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationRight];
				[self.tableView endUpdates];
			}
						
			//	however, if the index path updates are no longer accurate we just reload the whole table view
			else
			{
				[self.tableView reloadData];
				//	update whether we should just reload the table view next time
				//	we might want to do this because the thread that made the changes which effected this update will also now be inaccurate
				//	therefore we just reload on that thread too, and if this is that thread, is switches the 'justReload' back to NO
				self.justReload			= !self.justReload;
			}
						
			//	we do this to reload the section headers
			NSTimeInterval delayInSeconds	= 0.3f;
			dispatch_time_t delayDispatch	= dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
						
			dispatch_after(delayDispatch, dispatch_get_main_queue(), ^(void)
			{
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
							  withRowAnimation:UITableViewRowAnimationFade];
			});
		});
	});
}

#pragma mark - RecipeSearchViewController Methods

/**
 *	Called when a view controller was added to recipe search view.
 *
 *	@param	viewController				The view controller which was added to the our child view.
 */
- (void)addedViewController:(UIViewController *)viewController
{
	[self addChildViewController:viewController];
	[viewController didMoveToParentViewController:self];
}

/**
 *	Asks the delegate whether the view is in a position to become the first responder.
 *
 *	@param	recipeSearchView			The view asking to become the first responder.
 *
 *	@return	YES if the view can become the first responder, NO otherwise.
 */
- (BOOL)recipeSearchViewCanBecomeFirstResponder:(RecipeSearchView *)recipeSearchVie
{
	if (self.slideNavigationController.controllerState != SlideNavigationSideControllerClosed)
	{
		[self.slideNavigationController popCentreViewControllerAnimated:YES];
		return NO;
	}
	
	return YES;
}

/**
 *	Sent to the delegate when a search will take place.
 */
- (void)searchWillExecute
{
	[self.activityIndicatorView performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
}

/**
 *	Called when a search was executed and returned with the results dictionary.
 *
 *	@param	results						The dictionary of results from the yummly response.
 */
- (void)searchExecutedForResults:(NSDictionary *)results
{
	if (!self.internetConnectionExists)
	{
		[self.activityIndicatorView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Connect to the Internet", @"internet is missing")
									message:NSLocalizedString(@"The search could not be executed due to a lack of internet juice.\nApologies.", @"internet warning")
								   delegate:self
						  cancelButtonTitle:NSLocalizedString(@"Understood", @"okay")
						  otherButtonTitles:nil] show];
		
		return;
	}
	
	//	set up the next centre view controller with the recipes it needs to display
	RecipesViewController *recipesVC	= [[RecipesViewController alloc] init];
	recipesVC.recipes					= results[kYummlyMatchesArrayKey];
	
	NSArray *searchTerms				= results[@"criteria"][@"terms"];
	if ([searchTerms respondsToSelector:@selector(lastObject)])
		recipesVC.searchPhrase			= [searchTerms lastObject];
	
	//	set up the next right view controller with the attributions it needs to display
	YummlyAttributionViewController *yummlyAttribution	= [[YummlyAttributionViewController alloc] initWithAttributionDictionary:results[kYummlyAttributionDictionaryKey]];
	
	[self.activityIndicatorView stopAnimating];
	
	//	present the next set of view controllers
	[self.slideNavigationController pushCentreViewController:recipesVC
									 withRightViewController:yummlyAttribution
													animated:YES];
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
 *	A constraint used to centre the sliding cues in the view.
 *
 *	@return	An initialised NSLayoutConstraint to centre the cues.
 */
- (NSLayoutConstraint *)centreCueConstraint
{
	if (!_centreCueConstraint)
		_centreCueConstraint			= [NSLayoutConstraint constraintWithItem:self.slideCueLeft
															  attribute:NSLayoutAttributeCenterY
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.view
															  attribute:NSLayoutAttributeCenterY
															 multiplier:1.0f
															   constant:0.0f];
	
	return _centreCueConstraint;
}

/**
 *	A button that allows the user to reset the entire search.
 *
 *	@return	A fully initialise button targeted to a method which resets the Yummly Search.
 */
- (UIButton *)clearSearchButton
{
	if (!_clearSearchButton)
	{
		_clearSearchButton							= [[UIButton alloc] init];
		_clearSearchButton.enabled					= NO;
		_clearSearchButton.titleLabel.font			= kYummlyBolderFontWithSize(16.0f);
		_clearSearchButton.titleLabel.textAlignment	= NSTextAlignmentCenter;
		[_clearSearchButton setTitle:NSLocalizedString(@"Reset Search", @"reset the search") forState:UIControlStateNormal];
		[_clearSearchButton setTitleColor:[UIColor colorWithRed:0.8f green:0.3f blue:0.3f alpha:1.0f] forState:UIControlStateNormal];
		[_clearSearchButton setTitleColor:[UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.3f] forState:UIControlStateDisabled];
		_clearSearchButton.opaque					= YES;
		
		[_clearSearchButton addTarget:self action:@selector(resetSearchTapped) forControlEvents:UIControlEventTouchUpInside];
		
		_clearSearchButton.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_clearSearchButton];
	}
	
	return _clearSearchButton;
}

/**
 *	An image to be used in the slide cues on both sides of the view.
 *
 *	@return	An initialised and scaled UIImage.
 */
- (UIImage *)cueImage
{
	if (!_cueImage)
	{
		_cueImage						= [UIImage imageNamed:@"image_slidecue"];
		_cueImage						= [[UIImage alloc] initWithCGImage:_cueImage.CGImage
													scale:_cueImage.scale * 4.0f
											  orientation:_cueImage.imageOrientation];
	}
	
	return _cueImage;
}

/**
 *	Allows the user to open their list of favourites.
 *
 *	@return	A BiggerButton that allows the user to open their list of favourites.
 */
- (BiggerButton *)favouritesButton
{
	if (!_favouritesButton)
	{
		_favouritesButton				= [[BiggerButton alloc] init];
		
		_favouritesButton.opaque		= YES;
		
		[_favouritesButton setImage:[UIImage imageNamed:@"button_main_selected_favourite"] forState:UIControlStateNormal];
		[_favouritesButton setImage:[UIImage imageNamed:@"button_main_normal_favourite"] forState:UIControlStateHighlighted];
		
		[_favouritesButton addTarget:self action:@selector(favouritesTapped) forControlEvents:UIControlEventTouchUpInside];
		
		_favouritesButton.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_favouritesButton];
	}
	
	return _favouritesButton;
}

/**
 *	A view configured to display helpful text to the user.
 *
 *	@return	An initialised RecipeSearchHelpView.
 */
- (RecipeSearchHelpView *)helpView
{
	if (!_helpView)
	{
		_helpView						= [[RecipeSearchHelpView alloc] init];
		
		_helpView.opaque				= YES;
		
		_helpView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_helpView];
	}
	
	return _helpView;
}

/**
 *	The left slide navigation bar button used to slide in the left view.
 *
 *	@return	An initialised and targeted UIBarButtonItem to be used as the left bar button item.
 */
- (UIBarButtonItem *)leftButton
{
	if (!_leftButton)
	{
		UIImage *leftButtonImage		= [UIImage imageNamed:@"barbuttonitem_main_normal_hamburger_yummly"];
		
		_leftButton						= [[UIBarButtonItem alloc] initWithImage:leftButtonImage
															style:UIBarButtonItemStylePlain
														   target:self
														   action:@selector(leftButtonTapped)];
	}
	
	return _leftButton;
}

/**
 *	The gesture recogniser intended to be attached to every view other than the search view so the bar is resigned appropriately.
 *
 *	@return	A UITapGestureRecogniser that calls acts as though the user finished editing the search bar.
 */
- (UITapGestureRecognizer *)resignGestureRecogniser
{
	if (!_resignGestureRecogniser)
	{
		_resignGestureRecogniser		= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
		_resignGestureRecogniser.delegate				= self;
		_resignGestureRecogniser.numberOfTapsRequired	= 1;
	}
	
	return _resignGestureRecogniser;
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
 *	The table view representing the chosen ingredients for the recipe search.
 *
 *	@return	An initialised and designed table view for use showing included ingredients.
 */
- (UITableView *)tableView
{
	//	use lazy instantiation to set up the table view
	if (!_tableView)
	{
		_tableView					= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.allowsSelection	= YES;
		_tableView.allowsSelectionDuringEditing	= YES;
		_tableView.backgroundColor	= [UIColor whiteColor];
		_tableView.backgroundView	= nil;
		_tableView.clipsToBounds	= YES;
		_tableView.opaque			= YES;
		_tableView.separatorColor	= [UIColor clearColor];
		_tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
		
		//	we are in complete control of this table view
		_tableView.dataSource		= self;
		_tableView.delegate			= self;
		
		//	the only type of cell this table view uses is the standard one
		[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_tableView];
	}
	
	return _tableView;
}

/**
 *	This is the main view that allows the user to search.
 *
 *	@return	A fully initiased view with ourselves as the delegate.
 */
- (RecipeSearchView *)recipeSearchView
{
	//	use lazy instantiation to initialise the view
	if (!_recipeSearchView)
	{
		_recipeSearchView				= [[RecipeSearchView alloc] init];
		_recipeSearchView.delegate		= self;
		_recipeSearchView.opaque		= YES;
		
		_recipeSearchView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_recipeSearchView];
	}
	
	return _recipeSearchView;
}

/**
 *	The ingredients selected by the left controller.
 *
 *	@return	An array of ingredients to include in the recipes we search for.
 */
- (NSMutableDictionary *)selectedIngredients
{
	if (!_selectedIngredients)
		_selectedIngredients			= [@{kExcludedSelections: @[],
											 kIncludedSelections: @[]	} mutableCopy];
	
	return _selectedIngredients;
}

/**
 *	A constraint used to centre the sliding cues in the view.
 *
 *	@return	An initialised NSLayoutConstraint to centre the cues.
 */
- (NSArray *)shiftedCueConstraints
{
	if (!_shiftedCueConstraints)
		_shiftedCueConstraints				= [NSLayoutConstraint constraintsWithVisualFormat:@"V:[cueLeft]-(20)-[tableView]"
																			options:kNilOptions
																			metrics:nil
																			  views:self.viewsDictionary];
	return _shiftedCueConstraints;
}

/**
 *	A cue to the left of the view that indicates it can be slid right.
 *
 *	@return	An initialised UIImageView with an image acting as a cue.
 */
- (UIImageView *)slideCueLeft
{
	if (!_slideCueLeft)
	{
		_slideCueLeft						= [[UIImageView alloc] initWithImage:self.cueImage];
		_slideCueLeft.contentMode			= UIViewContentModeScaleAspectFit;
		_slideCueLeft.transform				= CGAffineTransformMakeRotation(M_PI);
		
		_slideCueLeft.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_slideCueLeft];
	}
	
	return _slideCueLeft;
}

/**
 *	A cue to the right of the view that indicates it can be slid left.
 *
 *	@return	An initialised UIImageView with an image acting as a cue.
 */
- (UIImageView *)slideCueRight
{
	if (!_slideCueRight)
	{
		_slideCueRight						= [[UIImageView alloc] initWithImage:self.cueImage];
		_slideCueRight.contentMode			= UIViewContentModeScaleAspectFit;
		
		_slideCueRight.translatesAutoresizingMaskIntoConstraints		= NO;
		[self.view addSubview:_slideCueRight];
	}
	
	return _slideCueRight;
}

/**
 *	A button that, when tapped, shows the user the intro tutorial.
 *
 *	@return	An initialised BiggerButton to show the user the tutorial when tapped.
 */
- (BiggerButton *)tutorialButton
{
	if (!_tutorialButton)
	{
		_tutorialButton					= [[BiggerButton alloc] init];
		[_tutorialButton setTitle:@"?" forState:UIControlStateNormal];
		[_tutorialButton setTitleColor:kYummlyColourMain forState:UIControlStateNormal];
		[_tutorialButton setTitleColor:kYummlyColourShadow forState:UIControlStateHighlighted];
		[_tutorialButton addTarget:self action:@selector(tutorialTapped) forControlEvents:UIControlEventTouchUpInside];
		
		_tutorialButton.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_tutorialButton];
	}
	
	return _tutorialButton;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"activityView"		: self.activityIndicatorView,
				@"clearSearchButton": self.clearSearchButton,
				@"cueLeft"			: self.slideCueLeft,
				@"cueRight"			: self.slideCueRight,
				@"favourites"		: self.favouritesButton,
				@"helpView"			: self.helpView,
				@"recipeSearchView"	: self.recipeSearchView,
				@"tableView"		: self.tableView,
				@"tutorialButton"	: self.tutorialButton	};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets whether the slide cues should be shifted up or down.
 *
 *	@param	shiftCuesUp					YES to shift the cues up, NO to centre them.
 */
- (void)setShiftCuesUp:(BOOL)shiftCuesUp
{
	if (_shiftCuesUp == shiftCuesUp)	return;
	
	_shiftCuesUp						= shiftCuesUp;
	
	[self.helpView setHidden:shiftCuesUp animated:YES];
	
	if (_shiftCuesUp)
	{
		[self.view removeConstraint:self.centreCueConstraint];
		[self.view addConstraints:self.shiftedCueConstraints];
	}
	
	else
	{
		[self.view removeConstraints:self.shiftedCueConstraints];
		[self.view addConstraint:self.centreCueConstraint];
	}
	
	[UIView animateWithDuration:0.5f animations:
	 ^{
		 [self.view layoutIfNeeded];
	 }];
}

#pragma mark - Slide Navigation Controller Lifecycle

/**
 *	Called when this view controller has been made the main centreViewController of the slideNavigationController.
 */
- (void)centreViewControllerMadeCentre
{
	self.favouritesButton.enabled		= YES;
}

/**
 *	Notifies the view controller that the parent slideNavigationController has closed all side views.
 */
- (void)slideNavigationControllerDidClose
{
}

/**
 *	Notifies the view controller that the parent slideNavigationController has open a side view.
 */
- (void)slideNavigationControllerDidOpen
{
}

/**
 *	Notifies the view controller that the parent slideNavigationController will close all side views.
 */
- (void)slideNavigationControllerWillClose
{
	self.tutorialButton.enabled			= YES;
}

/**
 *	Notifies the view controller that the parent slideNavigationController will open a side view.
 */
- (void)slideNavigationControllerWillOpen
{
	self.selectedCellIndexPath			= nil;
	[self.tableView setEditing:NO animated:NO];
	self.tutorialButton.enabled			= NO;
}

#pragma mark - UIActionSheetDelegate

/**
 *	Sent to the delegate before an action sheet is dismissed.
 *
 *	@param	actionSheet					The action sheet that is about to be dismissed.
 *	@param	buttonIndex					The index of the button that was clicked. If this is the cancel button index, the action sheet is canceling.
 */
- (void)	   actionSheet:(UIActionSheet *)actionSheet
willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex)
	{
		[appDelegate.yummlyRequest reset];
	}
	else if (buttonIndex == actionSheet.cancelButtonIndex)
		;
}

#pragma mark - UIGestureRecognizerDelegate Methods

/**
 *	Ask the delegate if a gesture recognizer should receive an object representing a touch.
 *
 *	@param	gestureRecognizer			An instance of a subclass of the abstract base class UIGestureRecognizer.
 *	@param	touch						A UITouch object from the current multi-touch sequence.
 *
 *	@return	YES to allow the gesture recognizer to examine the touch object, NO to prevent the gesture recognizer from seeing this touch object.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	   shouldReceiveTouch:(UITouch *)touch
{
	if (self.slideNavigationController.controllerState == SlideNavigationSideControllerClosed && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
		return YES;
	
	return NO;
}

#pragma mark - UIResponder Methods

/**
 *	Notifies the receiver that it has been asked to relinquish its status as first responder in its window.
 *
 *	@return	YES - resigning first responder status or NO, refusing to relinquish first responder status.
 */
- (BOOL)resignFirstResponder
{
	[self.recipeSearchView resignFirstResponder];
	return [super resignFirstResponder];
}

#pragma mark - UITableViewDataSource Methods

/**
 *	Asks the data source to return the number of sections in the table view.
 *
 *	@param	tableView					The number of sections in tableView. The default value is 1.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

/**
 *	Asks the data source to verify that the given row is editable.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	indexPath					An index path locating a row in tableView.
 *
 *	@return	YES if the row indicated by indexPath is editable; otherwise, NO.
 */
- (BOOL)	tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath isEqual:self.selectedCellIndexPath])
		return YES;
	
	return NO;
}

/**
 *	Asks the data source for a cell to insert in a particular location of the table view.
 *
 *	@param	tableView					A table-view object requesting the cell.
 *	@param	indexPath					An index path locating a row in tableView.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell				= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	NSArray *arrayForSection			= [self ingredientsArrayForSection:indexPath.section];
	NSString *cellText;
	
	cellText						= [arrayForSection[indexPath.row][kYummlyMetadataDescriptionKey] capitalizedString],
	cell.textLabel.textAlignment	= NSTextAlignmentNatural;
	
	cell.textLabel.text					= cellText;
	
	cell.selectionStyle					= UITableViewCellSelectionStyleNone;
	
	return cell;
}


/**
 *	Asks the data source to commit the insertion or deletion of a specified row in the receiver.
 *
 *	@param	tableView					The table-view object requesting the insertion or deletion.
 *	@param	editingStyle				The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath.
 *	@param	indexPath					An index path locating the row in tableView.
 */
- (void) tableView:(UITableView *)				tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)				indexPath
{
	if (!self.hasBeenSlid)				return;
	
	NSString *key						= indexPath.section == kSectionExcludedIndex ? kExcludedSelections : kIncludedSelections;
	NSDictionary *ingredientDictionary	= ((NSArray *)self.selectedIngredients[key])[indexPath.row];
	
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		self.selectedCellIndexPath		= nil;
		[self.tableView setEditing:NO animated:NO];
		self.modifiedIngredients(ingredientDictionary);
	}
}

/**
 *	Tells the data source to return the number of rows in a given section of a table view.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	section						An index number identifying a section in tableView.
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	NSArray *arrayForSection			= [self ingredientsArrayForSection:section];
	
	return arrayForSection.count;
}

#pragma mark - UITableViewDelegate Methods

/**
 *	Tells the delegate that the specified row is now selected.
 *
 *	@param	tableView					A table-view object informing the delegate about the new row selection.
 *	@param	indexPath					An index path locating the new selected row in tableView.
 */
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.selectedCellIndexPath)
	{
		self.selectedCellIndexPath			= indexPath;
		[tableView setEditing:YES animated:YES];
	}
	
	else
	{
		if (![indexPath isEqual:self.selectedCellIndexPath])
		{
			self.selectedCellIndexPath			= indexPath;
			[tableView setEditing:NO animated:YES];
			[tableView setEditing:YES animated:YES];
		}
		
		else
		{
			self.selectedCellIndexPath			= nil;
			[tableView setEditing:NO animated:YES];
		}
	}
	
	[self resignFirstResponder];
}

/**
 *	Asks the delegate for the editing style of a row at a particular location in a table view.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	indexPath					An index path locating a row in tableView.
 *
 *	@return	The editing style of the cell for the row identified by indexPath.
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

/**
 *	Asks the delegate for the height to use for the header of a particular section.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	section						An index number identifying a section of tableView.
 *
 *	@return	A floating-point value that specifies the height (in points) of the header for section.
 */
- (CGFloat)	   tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
	NSArray *ingredientsArray			= [self ingredientsArrayForSection:section];
	
	if (ingredientsArray.count > 0)
		return 20.0f;
	
	return 0.0f;
}

/**
 *	Asks the delegate for a view object to display in the header of the specified section of the table view.
 *
 *	@param	tableView					The table-view object asking for the view object.
 *	@param	section						An index number identifying a section of tableView .
 *
 *	@return	A view object to be displayed in the header of section.
 */
- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
	//	get header view object and then just set the title
	UITableViewHeaderFooterView *headerView		= [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
	if (!headerView)
		headerView							= [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderIdentifier];
	
	headerView.textLabel.text				= section == kSectionExcludedIndex ? NSLocalizedString(@"Excluded", @"ingredients that have been excluded") : NSLocalizedString(@"Required", @"ingredients that have been required");
	headerView.contentView.backgroundColor	= [[UIColor alloc] initWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	headerView.textLabel.textColor			= [UIColor whiteColor];
	
	return headerView;
}

/**
 *	Tells the delegate the table view is about to draw a cell for a particular row.
 *
 *	@param	tableView					The table-view object informing the delegate of this impending event.
 *	@param	cell						A table-view cell object that tableView is going to use when drawing the row.
 *	@param	indexPath					An index path locating the row in tableView.
 */
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	background colour has to be set here
	[ThemeManager customiseTableViewCell:cell withTheme:nil];
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
	self.view.opaque					= YES;
}

/**
 *	Notifies the view controller that its view was added to a view hierarchy.
 *
 *	@param	animated					If YES, the view was added to the window using an animation.
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (![MakeAMealOfItIntroduction introductionHasBeenShown])
	{
		[MakeAMealOfItIntroduction showIntroductionViewWithFrame:self.view.superview.bounds inView:self.view.superview];
		[MakeAMealOfItIntroduction setIntroductionHasBeenShown:YES];
	}
}

@end
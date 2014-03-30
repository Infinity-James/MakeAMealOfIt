//
//  CupboardViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import <objc/runtime.h>
#import "CupboardViewController.h"
#import "IngredientTableViewCell.h"
#import "OverlayActivityIndicator.h"
#import "UIView+AutolayoutHelper.h"
#import "YummlyMetadata.h"

@import QuartzCore;

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier						= @"CupboardCellIdentifier";
static NSString *const kHeaderIdentifier					= @"HeaderViewIdentifier";
/**	Key to get the action block from an alert view.	*/
static void *const AlertViewActionBlockKey					= "AlertViewActionBlock";
/**	Height for the exclude all view.	*/
static CGFloat const ExcludeViewHeight						= 20.0f;
/**	Duration for the animation of fading in and out the exclude all view.	*/
static NSTimeInterval const AnimationDurationExcludeView	= 0.2f;
/**	A type of block which a accepts a modified ingredient and uses it in some way.	*/
typedef void(^ModifiedIngredientBlock)(NSDictionary *modifiedIngredient);

#pragma mark - Cupboard View Controller Private Class Extension

@interface CupboardViewController () <IngredientTableViewCellDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	Used to show that the recipe image is loading.	*/
@property (nonatomic, strong)	OverlayActivityIndicator	*activityIndicatorView;
/**	A block called when an ingredient has been deselected.	*/
@property (nonatomic, copy)		ModifiedIngredientBlock		deselectIngredientBlock;
/**	A view presenting an option to the user to exclude all filtered ingredients.	*/
@property (nonatomic, strong)	UIView						*excludeAll;
/**	The constraints to insert the exclude all view.	*/
@property (nonatomic, strong)	NSArray						*excludeViewAddConstraints;
/**	The constraints to remove the exclude all view.	*/
@property (nonatomic, strong)	NSArray						*excludeViewRemoveConstraints;
/**	An array of ingredient dictionaries filtered by the user's search.	*/
@property (atomic, strong)		NSArray						*filteredIngredients;
/**	An array of all of ingredient dictionaries.	*/
@property (nonatomic, strong)	NSArray						*ingredientsMetadata;
/**	A dictionary of all of the ingredients, with each one under a key of it's first letter.	*/
@property (nonatomic, strong)	NSMutableDictionary			*ingredientsForTableView;
/**	A comparator block that sorts letter before numbers and punctuation.	*/
@property (nonatomic, assign)	NSComparator				prioritiseLettersComparator;
/**	A comparator block that sorts letter before numbers and punctuation in ingredient dictionaries.	*/
@property (nonatomic, assign)	NSComparator				prioritiseLettersInDictionaryComparator;
/**	A UITapGestureRecogniser that calls acts as though the user finished editing the search bar.	*/
@property (nonatomic, strong)	UITapGestureRecognizer		*resignGestureRecogniser;
/**	This search bar will be used to search the ingredients table view.	*/
@property (nonatomic, strong)	UISearchBar					*searchBar;
/**	This is the controller, handling presentation of results from the user's search. */
@property (nonatomic, strong)	UISearchDisplayController	*searchDisplay;
/**	An array of the titles to be used for the sections in the table view.	*/
@property (nonatomic, strong)	NSArray						*sectionTitles;
/**	An array of currently selected ingredient dictioanries, either included or excluded.	*/
@property (nonatomic, strong)	NSMutableDictionary			*selectedIngredients;
/**	Whether or not the exclude view should be shown.	*/
@property (nonatomic, assign)	BOOL						shouldShowExcludeAllView;
/**	The table view used to display all of the ingredients.	*/
@property (nonatomic, strong)	UITableView					*tableView;

@end

#pragma mark - Cupboard View Controller Implementation

@implementation CupboardViewController {}

#pragma mark - Action & Selector Methods

/**
 *	Called when the user has tapped the 'exclude all' button.
 *
 *	@param	excludeButton				The button associated with calling this method.
 */
- (void)excludeAllButtonTapped:(UIButton *)excludeButton
{
	NSUInteger ingredientsCount			= self.filteredIngredients.count;
	
	if (ingredientsCount > 0)
	{
		NSString *message				= [[NSString alloc] initWithFormat:@"You are about to exclude %@ ingredients. %@",
										   @(ingredientsCount),
										   ingredientsCount > 20 ? @"That's quite a lot of ingredients, are you sure about this?" :
																	@"I know it's not that many ingredients, but are you sure?"];
		UIAlertView *alertView			= [[UIAlertView alloc] initWithTitle:@"Exclude All Presented Ingredients?"
																	message:message
																   delegate:self
														  cancelButtonTitle:@"Nope"
														  otherButtonTitles:@"Definitely", nil];
		
		__weak CupboardViewController *weakSelf	= self;
		
		void (^actionBlock)(NSInteger)	= ^(NSInteger buttonIndex)
		{
			if (buttonIndex == alertView.cancelButtonIndex)
				return;
			else
				[weakSelf excludeAllFilteredIngredients],
				[weakSelf performSelectorOnMainThread:@selector(appropriatelyHideOrShowExcludeView) withObject:nil waitUntilDone:NO];
		};
		
		//	attach the action block to the alert view
		objc_setAssociatedObject(alertView, AlertViewActionBlockKey, actionBlock, OBJC_ASSOCIATION_COPY);
		
		[alertView show];
	}
}

/**
 *	The user has tapped the view for excluding the filtered ingredients.
 *
 *	@param	pressGesture				The gesture recogniser responsible for sending this message.
 */
- (void)excludeAllViewPressed:(UILongPressGestureRecognizer *)pressGesture
{
	UIButton *excludeButton				= pressGesture.view.subviews[0];
	
	if (pressGesture.state == UIGestureRecognizerStateBegan)
		excludeButton.highlighted		= YES;
	else if (pressGesture.state == UIGestureRecognizerStateEnded)
	{
		[self excludeAllButtonTapped:excludeButton];
		excludeButton.highlighted		= NO;
	}
}

/**
 *	The user has updated their choice of text size.
 */
- (void)textSizeChanged
{
	[self.tableView reloadData];
}

/**
 *	Called when the global Yummly Request object has been reset.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenReset:(NSNotification *)notification
{
	if (self.searchDisplay.isActive)
		[self.searchDisplay setActive:NO animated:YES];
		
	
	for (NSIndexPath *selectedIndexPath in self.tableView.indexPathsForSelectedRows)
	{
		[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
	}
	
	self.selectedIngredients		= nil;
	[self.tableView reloadData];
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
	
	CGSize activityIndicatorSize		= self.activityIndicatorView.intrinsicContentSize;
	CGFloat activityMargin				= (self.view.bounds.size.width - activityIndicatorSize.width - kPanelWidth) / 2.0f;
	
	//	add the table view to cover the whole main view except for the search bar
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]-(Panel)-|"
																	  options:kNilOptions
																	  metrics:@{@"Panel": @(kPanelWidth)}
																		views:self.viewsDictionary]];
	
	if (self.shouldShowExcludeAllView)
			[self.view addConstraints:self.excludeViewAddConstraints];
	else
			[self.view addConstraints:self.excludeViewRemoveConstraints];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(128)-[activityView(==height)]"
																	  options:kNilOptions
																	  metrics:@{@"height": @(activityIndicatorSize.height)}
																		views:self.viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[activityView(==width)]"
																	  options:kNilOptions
																	  metrics:@{@"margin"	: @(activityMargin),
																				@"width"	: @(activityIndicatorSize.width)}
																		views:self.viewsDictionary]];
	
}

#pragma mark - Convenience & Helper Methods

/**
 *	Returns an index path for a specified ingredient dictionary.
 *
 *	@param	ingredientDictionary		The ingredient dictionary to find the index path for in a table view.
 *	@param	tableView					The table view we want the index path to refer to.
 *
 *	@return	An NSIndexPath with the row and section for the passed in ingredientDictionary.
 */
- (NSIndexPath *)indexPathForIngredientDictionary:(NSDictionary *)ingredientDictionary
									  inTableView:(UITableView *)tableView
{
	NSArray *sectionTitles				= self.sectionTitles;
	
	if (tableView == self.tableView)
	{
		for (NSUInteger sectionTitleIndex = 0; sectionTitleIndex < sectionTitles.count; sectionTitleIndex++)
			for (NSUInteger ingredientIndex = 0; ingredientIndex < ((NSArray *)self.ingredientsForTableView[sectionTitles[sectionTitleIndex]]).count; ingredientIndex++)
				if ([(NSDictionary *)self.ingredientsForTableView[sectionTitles[sectionTitleIndex]][ingredientIndex] isEqualToDictionary:ingredientDictionary])
					return [NSIndexPath indexPathForRow:ingredientIndex inSection:sectionTitleIndex];
	}
	
	else if (tableView == self.searchDisplay.searchResultsTableView)
		for (NSUInteger index = 0; index < self.filteredIngredients.count; index++)
			if ([self.filteredIngredients[index] isEqualToDictionary:ingredientDictionary])
				return [NSIndexPath indexPathForRow:index inSection:1];
	
	return nil;
}

/**
 *	Returns an ingredient dictionary for an index path in a table view.
 *
 *	@param	indexPath					The index path of the item in the table view.
 *	@param	tableView					The table view that the index path refers to.
 *
 *	@return	An NSDictionary with the details of the ingredient at the passed in index path.
 */
- (NSDictionary *)ingredientDictionaryForIndexPath:(NSIndexPath *)indexPath
									   inTableView:(UITableView *)tableView
{
	NSDictionary *ingredientDictionary;
	
	if (tableView == self.searchDisplay.searchResultsTableView && self.filteredIngredients.count > indexPath.row)
		ingredientDictionary			= self.filteredIngredients[indexPath.row];
	else
		ingredientDictionary			= self.ingredientsForTableView[self.sectionTitles[indexPath.section]][indexPath.row];
	
	return ingredientDictionary;
}

#pragma mark - Searching Management

/**
 *	Excludes all ingredients currently in the filteredIngredients array.
 */
- (void)excludeAllFilteredIngredients
{
	dispatch_async(dispatch_queue_create("Excluding Ingredients", NULL),
	^{
		NSArray *excludedIngredients		= self.selectedIngredients[kExcludedSelections];
		self.selectedIngredients[kExcludedSelections] = [excludedIngredients arrayByAddingObjectsFromArray:self.filteredIngredients];
		[self tableView:self.searchDisplay.searchResultsTableView selected:YES ingredientDictionaries:self.filteredIngredients forSection:kExcludedSelections];
					   
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.searchDisplay.searchResultsTableView reloadRowsAtIndexPaths:self.searchDisplay.searchResultsTableView.indexPathsForVisibleRows
															 withRowAnimation:UITableViewRowAnimationAutomatic];
		});
	});
}

/**
 *	Filters the contents of the table view according to the search of the user.
 *
 *	@param	searchText					The search phrase.
 *	@param	scope						The scope under which to use the search phrase.
 */
- (void)filterContentForSearchText:(NSString *)searchText inScope:(NSString *)scope
{
	//	first remove all past search results
	self.filteredIngredients			= @[];
	
	//	define the predicate according to the search of the user
	NSPredicate *predicate				= [NSPredicate predicateWithFormat:@"SELF.%@ CONTAINS[cd] %@", kYummlyMetadataDescriptionKey, searchText];
	NSArray *filtered					= [self.ingredientsMetadata filteredArrayUsingPredicate:predicate];
	
	dispatch_sync(dispatch_get_main_queue(),
	^{
		self.filteredIngredients		= filtered;
	});
}

/**
 *	Called when the searchDisplayController's tableView should be reloaded.
 */
- (void)reloadSearchTableView
{
	[self.searchDisplay.searchResultsTableView reloadData];
	[self.activityIndicatorView stopAnimating];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(scrollToTopOfTableView:)
											   object:self.searchDisplay.searchResultsTableView];
	[self performSelector:@selector(scrollToTopOfTableView:)
			   withObject:self.searchDisplay.searchResultsTableView
			   afterDelay:0.5];
}

/**
 *	Scrolls to the top of the given table view.
 *
 *	@param	tableView					The table view to scroll to the top of.
 */
- (void)scrollToTopOfTableView:(UITableView *)tableView
{
	tableView.contentOffset				= CGPointZero;
}

/**
 *	Will hide or show the exclude view depending on what should be done.
 */
- (void)appropriatelyHideOrShowExcludeView
{
	if (!self.shouldShowExcludeAllView && !self.excludeAll.superview)
		return;
	else if (self.shouldShowExcludeAllView)
	{
		[self.view addSubviewForAutoLayout:self.excludeAll];
		[self.view bringSubviewToFront:self.excludeAll];
		[self.view removeConstraints:self.excludeViewRemoveConstraints];
		[self.view addConstraints:self.excludeViewAddConstraints];
		
		CGRect frame					= CGRectMake(0.0f, ExcludeViewHeight, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
		
		[UIView animateWithDuration:AnimationDurationExcludeView
						 animations:
		^{
			self.excludeAll.alpha		= 1.0f;
			[self.view layoutIfNeeded];
			self.searchDisplay.searchResultsTableView.frame	= frame;
		}];
	}
	else
	{
		[self.view removeConstraints:self.excludeViewAddConstraints];
		[self.view addConstraints:self.excludeViewRemoveConstraints];
		
		CGRect frame					= CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
		
		[UIView animateWithDuration:AnimationDurationExcludeView
						 animations:
		^{
			self.excludeAll.alpha		= 0.0f;
			[self.view layoutIfNeeded];
			self.searchDisplay.searchResultsTableView.frame	= frame;
		}
						completion:^(BOOL finished)
		{
			[self.excludeAll removeFromSuperview];
		}];
	}
}

/**
 *	Sets the the search display controller's table view properties.
 *
 *	@param	searchDisplayTableView		The table view displayed by the UISearchDisplayController.
 */
- (void)sortOutSearchDisplayControllerTableView:(UITableView *)searchDisplayTableView
{
	searchDisplayTableView.dataSource	= self;
	searchDisplayTableView.delegate		= self;
	[self appropriatelyHideOrShowExcludeView];
	CGRect frame						= CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
	searchDisplayTableView.frame		= frame;
	[searchDisplayTableView registerClass:[IngredientTableViewCell class]
				   forCellReuseIdentifier:kCellIdentifier];
	
}

/**
 *	Unloads the search display controller's table view's accesory views and so forth.
 *
 *	@param	searchDisplayTableView		The table view displayed by the UISearchDisplayController.
 */
- (void)unloadSearchDisplayControllerTableView:(UITableView *)searchDisplayTableView
{
	[self appropriatelyHideOrShowExcludeView];
}

#pragma mark - IngredientTableViewCellDelegate Methods

/**
 *	Sent to the delegate when a cell has been told to exclude it's ingredient.
 *
 *	@param	ingredientTableViewCell		The ingredient cell that has been updated in some way (included or excluded, or an undo of either).
 */
- (void)ingredientCellUpdated:(IngredientTableViewCell *)ingredientTableViewCell
{
	//	get the array of included and excluded ingredient dictionaries
	NSMutableArray *included			= [self.selectedIngredients[kIncludedSelections] mutableCopy];
	NSMutableArray *excluded			= [self.selectedIngredients[kExcludedSelections] mutableCopy];
	
	//	get the table view to use when updating
	UITableView *tableView				= self.searchDisplay.searchResultsTableView ? self.searchDisplay.searchResultsTableView : self.tableView;
	
	//	create some boolean values to set when updating the selection
	__block BOOL excludedUpdate			= NO;
	__block BOOL includedUpdate			= NO;
	__block BOOL selected				= NO;
	
	//	asynchronously update everything to keep work off main thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
	^{
		if (ingredientTableViewCell.included && ![included containsObject:ingredientTableViewCell.ingredientDictionary])
		{
			//	add the selection to the dictionary
			[included addObject:ingredientTableViewCell.ingredientDictionary];
		   
			//	specify the ingredient was selected
			selected					= YES;
		   
			//	flag that this ingredient's included status was updated
			includedUpdate				= YES;
		}
	   
		else if (!ingredientTableViewCell.included && [included containsObject:ingredientTableViewCell.ingredientDictionary])
		{
			//	remove the selection from the dictionary
			[included removeObject:ingredientTableViewCell.ingredientDictionary];
		   
			//	specify the ingredient was removed
			selected					= NO;
		   
			//	flag that this ingredient's included status was updated
			includedUpdate				= YES;
		}
	   
		//	update the dictionary with the new inclusions
		self.selectedIngredients[kIncludedSelections]	= included;
	   
		if (includedUpdate)
			//	update the left controller with the selected / unselected ingredient dictionary
			[self tableView:tableView
				   selected:selected
	   ingredientDictionary:ingredientTableViewCell.ingredientDictionary
				 forSection:kIncludedSelections];
	   
		if (ingredientTableViewCell.excluded && ![excluded containsObject:ingredientTableViewCell.ingredientDictionary])
		{
			//	add the selection to the dictionary
			[excluded addObject:ingredientTableViewCell.ingredientDictionary];
		   
			//	specify the ingredient was selected
			selected					= YES;
		   
			//	flag that this ingredient's excluded status was updated
			excludedUpdate				= YES;
		}
	   
		else if (!ingredientTableViewCell.excluded && [excluded containsObject:ingredientTableViewCell.ingredientDictionary])
		{
			//	remove the selection from the dictionary
			[excluded removeObject:ingredientTableViewCell.ingredientDictionary];
		   
			//	specify the ingredient was removed
			selected					= NO;
		   
			//	flag that this ingredient's excluded status was updated
			excludedUpdate				= YES;
		}
	   
		//	update the dictionary with the new exclusions
		self.selectedIngredients[kExcludedSelections]	= excluded;
		
		if (excludedUpdate)
			//	update the left controller with the selected / unselected ingredient dictionary
			[self tableView:tableView
				   selected:selected
	   ingredientDictionary:ingredientTableViewCell.ingredientDictionary
				 forSection:kExcludedSelections];
	});
	
}

#pragma mark - Initialisation

/**
 *	Asynchronously gets the ingredient dictionaries and then reloads the table view with them.
 */
- (void)getIngredientsDictionaries
{
	dispatch_async(dispatch_queue_create("Ingredients Fetcher", NULL),
	^{
		self.ingredientsMetadata	= [YummlyMetadata allMetadata][kYummlyMetadataIngredients];
		[self setupTableViewIndex];
		[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	});
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
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(yummlyRequestHasBeenReset:)
													 name:kNotificationYummlyRequestReset
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(textSizeChanged)
													 name:kNotificationTextSizeChanged
												   object:nil];
	}
	
	return self;
}

/**
 *	This will be responsible for setting up the sections and the index titles for the table view.
 */
- (void)setupTableViewIndex
{
	for (NSDictionary *ingredientDictionary in self.ingredientsMetadata)
	{
		NSString *ingredient			= ingredientDictionary[kYummlyMetadataDescriptionKey];
		NSString *firstCharacter		= [ingredient substringWithRange:NSMakeRange(0, 1)];
		NSMutableArray *ingredients		= self.ingredientsForTableView[firstCharacter];
		
		if (!ingredients)
			ingredients					= [[NSMutableArray alloc] init];
		
		[ingredients addObject:ingredientDictionary];
		
		self.ingredientsForTableView[firstCharacter]	= ingredients;
	}
}

#pragma mark - Left Delegate Methods

/**
 *	Called when a particular ingredient dictionary was selected in the table view.
 *
 *	@param	tableView					The table view object wherein the ingredient dictionary was selected.
 *	@param	isSelected					Whether the ingredient dictionary was selected or deselected.
 *	@param	ingredientDictionary		The ingredient dictionary that was either selected or deselected.
 *	@param	inclusionExclusionKey		Either kExcludedSelections to exclude the dictionary, or kIncludedSelections to include it.
 */
- (void)   tableView:(UITableView *)tableView
			selected:(BOOL)isSelected
ingredientDictionary:(NSDictionary *)ingredientDictionary
		  forSection:(NSString *)inclusionExclusionKey
{
	[self tableView:tableView selected:isSelected ingredientDictionaries:@[ingredientDictionary] forSection:inclusionExclusionKey];
}

/**
 *	Called when ingredient dictionaries are selected in the table view for one key.
 *
 *	@param	tableView					The table view object wherein the ingredient dictionary was selected.
 *	@param	isSelected					Whether the ingredient dictionary was selected or deselected.
 *	@param	ingredientDictionary		The ingredient dictionary that was either selected or deselected.
 *	@param	inclusionExclusionKey		Either kExcludedSelections to exclude the dictionary, or kIncludedSelections to include it.
 */
- (void)     tableView:(UITableView *)tableView
   			  selected:(BOOL)isSelected
ingredientDictionaries:(NSArray *)ingredientDictionaries
 		    forSection:(NSString *)inclusionExclusionKey
{
	//	initialise arrays to hold every selected ingredient, included or excluded
	NSMutableArray *allExcluded			= [[NSMutableArray alloc] init];
	NSMutableArray *allIncluded			= [[NSMutableArray alloc] init];
	
	for (NSDictionary *ingredientDictionary in self.selectedIngredients[kExcludedSelections])
		[allExcluded addObject:ingredientDictionary];
	for (NSDictionary *ingredientDictionary in self.selectedIngredients[kIncludedSelections])
		[allIncluded addObject:ingredientDictionary];
	
	NSArray *update						= ingredientDictionaries;
	
	NSMutableDictionary *addedSelections		= [@{kExcludedSelections	: @[],
													 kIncludedSelections	: @[]} mutableCopy];
	NSMutableDictionary *removedSelections		= [@{kExcludedSelections	: @[],
													 kIncludedSelections	: @[]} mutableCopy];
	
	if (inclusionExclusionKey == kExcludedSelections || inclusionExclusionKey == kIncludedSelections)
	{
		//	update the array appropriately according to whether it is selected or not
		if (!isSelected)
		{
			removedSelections[inclusionExclusionKey]	= update;
		}
		else
		{
			addedSelections[inclusionExclusionKey]		= update;
		}
	}
	
	//	make a dictionary with the updates to send to the left view controller
	NSDictionary *updates				= @{kAddedSelections	: addedSelections,
											kAllSelections		: @{kExcludedSelections: allExcluded,	kIncludedSelections: allIncluded},
											kRemovedSelections	: removedSelections};
	
	//	make sure this is performed on the main thread
	dispatch_async(dispatch_get_main_queue(),
	^{
		[self.leftDelegate leftController:self updatedWithSelections:updates];
	});
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
 *	A block called when an ingredient has been deselected.
 *
 *	@return	A block called when an ingredient has been deselected.
 */
- (ModifiedIngredientBlock)deselectIngredientBlock
{
	if (!_deselectIngredientBlock)
	{
		//	get a weak pointer to our self to be used in the block
		__weak CupboardViewController *weakSelf	= self;
		
		_deselectIngredientBlock		= ^(NSDictionary *deselectedIngredient)
		{
			dispatch_async(dispatch_queue_create("Modifying Selections", NULL),
			^{
				NSIndexPath *indexPath			= [weakSelf indexPathForIngredientDictionary:deselectedIngredient
																		  inTableView:weakSelf.tableView];
				IngredientTableViewCell *cell	= (IngredientTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
							   
				if (!cell)
					cell						= (IngredientTableViewCell *)[weakSelf tableView:weakSelf.tableView
														 cellForRowAtIndexPath:indexPath];
							   
				dispatch_async(dispatch_get_main_queue(),
				^{
					[weakSelf.searchDisplayController setActive:NO animated:YES];
												  
					if (cell.excluded)
						[cell setExcluded:NO updated:YES animated:NO];
					else if (cell.included)
						[cell setIncluded:NO updated:YES animated:NO];
												  
					[weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath]
											  withRowAnimation:UITableViewRowAnimationAutomatic];
				});
			});
		};
	}
	
	return _deselectIngredientBlock;
}

/**
 *	A view presenting an option to the user to exclude all filtered ingredients.
 *
 *	@return	A view presenting an option to the user to exclude all filtered ingredients.
 */
- (UIView *)excludeAll
{
	if (!_excludeAll)
	{
		_excludeAll						= [[UIView alloc] init];
		_excludeAll.alpha				= 0.0f;
		_excludeAll.backgroundColor		= kYummlyColourMainWithAlpha(0.9f);
		
		UIButton *excludeAllButton		= [[UIButton alloc] init];
		excludeAllButton.backgroundColor= [UIColor clearColor];
		excludeAllButton.titleLabel.font= kYummlyBolderFontWithSize(FontSizeForTextStyle(UIFontTextStyleCaption1));
		[excludeAllButton setTitle:@"Exclude All" forState:UIControlStateNormal];
		[excludeAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[excludeAllButton setTitleColor:[[UIColor alloc] initWithWhite:0.9f alpha:0.7f] forState:UIControlStateHighlighted];
		excludeAllButton.userInteractionEnabled	= NO;
		
		UILongPressGestureRecognizer *longGesture	= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(excludeAllViewPressed:)];
		longGesture.minimumPressDuration= 0.0f;
		[_excludeAll addGestureRecognizer:longGesture];
		
		[_excludeAll addSubviewForAutoLayout:excludeAllButton];
		
		[_excludeAll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[excludeButton]"
																			options:kNilOptions
																			metrics:nil
																			  views:@{@"excludeButton": excludeAllButton}]];
		[_excludeAll addConstraint:[NSLayoutConstraint constraintWithItem:excludeAllButton
																attribute:NSLayoutAttributeCenterY
																relatedBy:NSLayoutRelationEqual
																   toItem:_excludeAll
																attribute:NSLayoutAttributeCenterY
															   multiplier:1.0f
																 constant:0.0f]];
		
		[_excludeAll bringSubviewToFront:excludeAllButton];
	}
	
	return _excludeAll;
}

/**
 *	The constraints to insert the exclude all view.
 *
 *	@return	The constraints to insert the exclude all view.
 */
- (NSArray *)excludeViewAddConstraints
{
	if (!_excludeViewAddConstraints)
		_excludeViewAddConstraints		= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar][excludeAll(height)][tableView]|"
																			  options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
																			  metrics:@{@"height" : @(ExcludeViewHeight)}
																				views:self.viewsDictionary];
	
	return _excludeViewAddConstraints;
}

/**
 *	The constraints to remove the exclude all view.
 *
 *	@return	The constraints to remove the exclude all view.
 */
- (NSArray *)excludeViewRemoveConstraints
{
	if (!_excludeViewRemoveConstraints)
		_excludeViewRemoveConstraints	= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar][tableView]|"
																				options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
																				metrics:nil
																				  views:self.viewsDictionary];
	
	return _excludeViewRemoveConstraints;
}

/**
 *	This dictionary will hold the sections and the objects pertaining to that section.
 *
 *	@return	A dictionary of all of the ingredients, with each one under a key of it's first letter.
 */
- (NSMutableDictionary *)ingredientsForTableView
{
	if (!_ingredientsForTableView)
		_ingredientsForTableView		= [[NSMutableDictionary alloc] init];
	
	return _ingredientsForTableView;
}

/**
 *	an array of possible placeholders for the search bar
 */
- (NSArray *)placeholders
{
	return @[@"Apple", @"Chicken", @"Chili Pepper", @"Cream", @"Flour", @"Fusilli", @"Milk Chocolate", @"Oats", @"Peanut Butter", @"Sugar", @"Vanilla"];
}

/**
 *	The getter for the comparator to use when sorting ingredient descriptions for the table view.
 *
 *	@return	A comparator block that sorts letter before numbers and punctuation.
 */
- (NSComparator)prioritiseLettersComparator
{
	if (!_prioritiseLettersComparator)
	{
		_prioritiseLettersComparator	= ^NSComparisonResult(NSString *stringA, NSString *stringB)
		{
			//	gets whether either first letter is a number
			BOOL isNumberA				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[stringA characterAtIndex:0]];
			BOOL isNumberB				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[stringB characterAtIndex:0]];
			
			//	we sort the letter over the number
			if (!isNumberA && isNumberB)
				return NSOrderedAscending;
			
			else if (isNumberA && !isNumberB)
				return NSOrderedDescending;
			
			//	if both or neither are numbers we sort normally
			return [stringA compare:stringB options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
		};
	}
	
	return _prioritiseLettersComparator;
}

/**
 *	The getter for the comparator to use when sorting ingredient dictionaries for the table view.
 *
 *	@return	A comparator block that sorts letter before numbers and punctuation in ingredient dictionaries.
 */
- (NSComparator)prioritiseLettersInDictionaryComparator
{
	if (!_prioritiseLettersInDictionaryComparator)
	{
		_prioritiseLettersInDictionaryComparator	= ^NSComparisonResult(NSDictionary *ingredientDictionaryA, NSDictionary *ingredientDictionaryB)
		{
			NSString *ingredientA		= ingredientDictionaryA[kYummlyMetadataDescriptionKey];
			NSString *ingredientB		= ingredientDictionaryB[kYummlyMetadataDescriptionKey];
			
			//	gets whether either first letter is a number
			BOOL isNumberA				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[ingredientA characterAtIndex:0]];
			BOOL isNumberB				= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[ingredientB characterAtIndex:0]];
			
			//	we sort the letter over the number
			if (!isNumberA && isNumberB)
				return NSOrderedAscending;
			
			else if (isNumberA && !isNumberB)
				return NSOrderedDescending;
			
			//	if both or neither are numbers we sort normally
			return [ingredientA compare:ingredientB options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
		};
	}
	
	return _prioritiseLettersInDictionaryComparator;
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
		_resignGestureRecogniser		= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarTextDidEndEditing:)];
		_resignGestureRecogniser.numberOfTapsRequired	= 1;
	}
	
	return _resignGestureRecogniser;
}

/**
 *	This search bar will be used to search the ingredients table view.
 *
 *	@return	A fully initialised and customised seach bar.
 */
- (UISearchBar *)searchBar
{
	if (!_searchBar)
	{
		_searchBar						= [[UISearchBar alloc] init];
		_searchBar.delegate				= self;
		_searchBar.opaque				= YES;
		_searchBar.placeholder			= [[NSString alloc] initWithFormat:@"%@...", self.placeholders[arc4random() % self.placeholders.count]];
		_searchBar.searchBarStyle		= UISearchBarIconSearch;
		_searchBar.showsScopeBar		= NO;
		[ThemeManager customiseSearchBar:_searchBar withTheme:nil];
		NSDictionary *attributes		= @{NSFontAttributeName				: kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleSubheadline)),
											NSForegroundColorAttributeName	: [UIColor whiteColor]};
		[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:attributes forState:UIControlStateNormal];
		
		
		_searchBar.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_searchBar];
	}
	
	return _searchBar;
}

/**
 *	The search display controller handling the searches of our table view.
 *
 *	@return	An initialised and configured UISearchDisplayController.
 */
- (UISearchDisplayController *)searchDisplay
{
	if (!_searchDisplay)
	{
		_searchDisplay					= [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_searchDisplay.delegate			= self;
	}
	
	return _searchDisplay;
}

/**
 *	An array of first letters for each ingredient to be used as sections.
 */
- (NSArray *)sectionTitles
{
	//	a sorted array of section titles
	return [self.ingredientsForTableView.allKeys sortedArrayUsingComparator:self.prioritiseLettersComparator];
}

/**
 *	A dictionationary holding all of the indices of the selected rows in our table view.
 *
 *	@return	A dictionary of all the currentl selected indices, kExcludedSelections for excluded ones, and kIncludedSelections for included ones.
 */
- (NSMutableDictionary *)selectedIngredients
{
	if (!_selectedIngredients)
		_selectedIngredients			= [@{ kExcludedSelections	: @[],
											  kIncludedSelections	: @[]} mutableCopy];
	
	return _selectedIngredients;
}

/**
 *	Whether or not the exclude view should be shown.
 *
 *	@return	YES if  the exclude view should be shown, NO otherwise.
 */
- (BOOL)shouldShowExcludeAllView
{
	NSUInteger selectedIngredientsCount	= self.filteredIngredients.count;
	for (NSArray *selectedIngredient in [self.selectedIngredients allValues])
		selectedIngredientsCount		+= selectedIngredient.count;
	
	if (self.searchDisplay.isActive && selectedIngredientsCount < 100 && self.filteredIngredients.count > 1)
		return YES;
	
	return NO;
}

/**
 *	The table view used to display all of the ingredients.
 *
 *	@return	A fully initialised table view added as a subview.
 */
- (UITableView *)tableView
{
	if (!_tableView)
	{
		_tableView						= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.allowsSelection		= NO;
		_tableView.dataSource			= self;
		_tableView.delegate				= self;
		_tableView.opaque				= YES;
		
		[_tableView registerClass:[IngredientTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_tableView];
	}
	
	return _tableView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"activityView"	: self.activityIndicatorView,
			 @"excludeAll"		: self.excludeAll,
			 @"searchBar"		: self.searchBar,
			 @"tableView"		: self.tableView};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Set the array of dictionaries each holding an ingredient object.
 *
 *	@param	ingredientsMetadata		The array of ingredient dictionaries.
 */
- (void)setIngredientsMetadata:(NSArray *)ingredientsMetadata
{
	//	sort the ingredients dictionary before adding them
	_ingredientsMetadata			= [ingredientsMetadata sortedArrayUsingComparator:self.prioritiseLettersInDictionaryComparator];
}

/**
 *	Called when our left controller delegate is set.
 *
 *	@param	leftDelegate			An NSObject adhering to our LeftControllerDelegate protocol interested in our updates.
 */
- (void)setLeftDelegate:(id<LeftControllerDelegate>)leftDelegate
{
	if (_leftDelegate == leftDelegate)
		return;
	
	_leftDelegate					= leftDelegate;
	
	//	if a valid left delegate was set we send it the block to execute if it modifies any of our data
	if (_leftDelegate)
		[_leftDelegate blockToExecuteWhenDataModified:self.deselectIngredientBlock];
}

#pragma mark - UIAlertViewDelegate Methods

/**
 *	Sent to the delegate when the user clicks a button on an alert view.
 *
 *	@param	alertView					The alert view containing the button.
 *	@param	buttonIndex					The index of the button that was clicked. The button indices start at 0.
 */
- (void)   alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//	get the action block from the alert view and call it
	void (^actionBlock)(NSInteger)		= objc_getAssociatedObject(alertView, AlertViewActionBlockKey);
	actionBlock(buttonIndex);
}

#pragma mark - UISearchBarDelegate Methods

/**
 *	Tells the delegate when the user begins editing the search text.
 *
 *	@param	searchBar					The search bar that is being edited.
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[searchBar becomeFirstResponder];
	
	[self.searchDisplay.searchResultsTableView addGestureRecognizer:self.resignGestureRecogniser];
	[self.tableView addGestureRecognizer:self.resignGestureRecogniser];
}

/**
 *	Tells the delegate that the user finished editing the search text.
 *
 *	@param	searchBar					The search bar that is being edited.
 */
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	[self.searchDisplay.searchResultsTableView removeGestureRecognizer:self.resignGestureRecogniser];
	[self.tableView removeGestureRecognizer:self.resignGestureRecogniser];
}

#pragma mark - UISearchDisplayDelegate Methods

/**
 *	Tells the delegate that the controller is about to display its table view.
 *
 *	@param	controller					The search display controller for which the receiver is the delegate.
 *	@param	tableView					The search display controller’s table view.
 */
- (void)searchDisplayController:(UISearchDisplayController *)controller
 willShowSearchResultsTableView:(UITableView *)tableView
{
	[self sortOutSearchDisplayControllerTableView:tableView];
}

/**
 *	Tells the delegate that the controller just hid its table view.
 *
 *	@param	controller					The search display controller for which the receiver is the delegate.
 *	@param	tableView					The search display controller’s table view.
 */
- (void)searchDisplayController:(UISearchDisplayController *)controller
  didHideSearchResultsTableView:(UITableView *)tableView
{
	[self unloadSearchDisplayControllerTableView:tableView];
}

/**
 *	Asks the delegate if the table view should be reloaded for a given scope.
 *
 *	@param	controller					The search display controller for which the receiver is the delegate.
 *	@param	searchOption				The index of the selected scope button in the search bar.
 */
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	return YES;
}

/**
 *	Asks the delegate if the table view should be reloaded for a given search string.
 *
 *	@param	controller					The search display controller for which the receiver is the delegate.
 *	@param	searchOption				The string in the search bar.
 */
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
	NSUInteger length					= searchString.length;
	
	if (length == 0)
		[self.activityIndicatorView stopAnimating];
	else if (length == 1)
		[self.view bringSubviewToFront:self.activityIndicatorView],
		[self.activityIndicatorView startAnimating];
	else
		[self.activityIndicatorView startAnimating];
	
	dispatch_async(dispatch_queue_create("Filtering", NULL),
	^{
		[self filterContentForSearchText:searchString inScope:nil];
		dispatch_async(dispatch_get_main_queue(),
		^{
			CGFloat delay				= 1.0f / length;
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadSearchTableView) object:nil];
			[NSObject cancelPreviousPerformRequestsWithTarget:self.activityIndicatorView];
			[self performSelector:@selector(reloadSearchTableView) withObject:nil afterDelay:delay];
			[self appropriatelyHideOrShowExcludeView];
		});
	});
	
	return NO;
}

#pragma mark - UITableViewDataSource Methods

/**
 *	Asks the data source to return the number of sections in the table view.
 *
 *	@param	tableView					The number of sections in tableView. The default value is 1.
 *
 *	@return	The number of sections in tableView.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return 1;
	
	return self.ingredientsForTableView.count;
}

/**
 *	Asks the data source to return the titles for the sections for a table view.
 *
 *	@param	tableView					The table-view object requesting this information.
 *
 *	@return	An array of strings that serve as the title of sections in the table view and appear in the index list for the table view.
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return nil;
	
	NSMutableArray *capitalisedTitles	= [[NSMutableArray alloc] init];
	
	for (NSString *title in self.sectionTitles)
		if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[title characterAtIndex:0]])
		{
			if (![capitalisedTitles containsObject:@"#"])
				[capitalisedTitles addObject:@"#"];
		}
		else
			[capitalisedTitles addObject:[title capitalizedString]];
	
	return capitalisedTitles;
}

/**
 *	Asks the data source for a cell to insert in a particular location of the table view.
 *
 *	@param	tableView					A table-view object requesting the cell.
 *	@param	indexPath					An index path locating a row in tableView.
 *
 *	@return	An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	IngredientTableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	cell.ingredientDictionary			= [self ingredientDictionaryForIndexPath:indexPath inTableView:tableView];
	
	if ([self.selectedIngredients[kIncludedSelections] containsObject:cell.ingredientDictionary])
		cell.included					= YES;
	else
		cell.included					= NO;
	
	if ([self.selectedIngredients[kExcludedSelections] containsObject:cell.ingredientDictionary])
		cell.excluded					= YES;
	else
		cell.excluded					= NO;
	
	cell.delegate						= self;
	
	return cell;
}

/**
 *	Tells the data source to return the number of rows in a given section of a table view.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	section						An index number identifying a section in tableView.
 *
 *	@return	The number of rows in section.
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return self.filteredIngredients.count;
	
	return ((NSArray *)self.ingredientsForTableView[self.sectionTitles[section]]).count;
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
	IngredientTableViewCell *ingredientCell		= (IngredientTableViewCell *)cell;
	
	if ([self.selectedIngredients[kIncludedSelections] containsObject:ingredientCell.ingredientDictionary])
		ingredientCell.included					= YES;
	else
		ingredientCell.included					= NO;
	
	if ([self.selectedIngredients[kExcludedSelections] containsObject:ingredientCell.ingredientDictionary])
		ingredientCell.excluded					= YES;
	else
		ingredientCell.excluded					= NO;
	
}

#pragma mark - UITableViewDelegate Methods

/**
 *	Asks the delegate for the height to use for the header of a particular section.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	section						An index number identifying a section of tableView .
 *
 *	@return	A floating-point value that specifies the height (in points) of the header for section.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return 0.0f;
	
	return 20.0f;
}

/**
 *	Asks the delegate for the height to use for a row in a specified location.
 *
 *	@param	tableView					The table-view object requesting this information.
 *	@param	indexPath					An index path that locates a row in tableView.
 */
- (CGFloat)	  tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [IngredientTableViewCell desiredHeightForCell];
}

/**
 *	Asks the delegate for a view object to display in the header of the specified section of the table view.
 *
 *	@param	tableView					The table-view object asking for the view object.
 *	@param	section						An index number identifying a section of tableView .
 *
 *	@return	A view object to be displayed in the header of section.
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplay.searchResultsTableView)
		return nil;
	
	//	get header view object and then just set the title
	UITableViewHeaderFooterView *headerView		= [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
	if (!headerView)
		headerView						= [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderIdentifier];
	headerView.textLabel.text			= [self.sectionTitles[section] capitalizedString];
	headerView.contentView.backgroundColor	= [[UIColor alloc] initWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	headerView.textLabel.textColor			= [UIColor whiteColor];
	
	return headerView;
}

#pragma mark - View Lifecycle

/**
 *	Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self getIngredientsDictionaries];
}

/**
 *	Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 *	@param	animated					If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
}

@end
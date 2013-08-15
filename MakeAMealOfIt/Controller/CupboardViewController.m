//
//  CupboardViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "CupboardViewController.h"
#import "IngredientTableViewCell.h"
#import "YummlyMetadata.h"

@import QuartzCore;

#pragma mark - Constants & Static Variables

static NSString *const kCellIdentifier	= @"CupboardCellIdentifier";
static NSString *const kHeaderIdentifier= @"HeaderViewIdentifier";

#pragma mark - Cupboard View Controller Private Class Extension

@interface CupboardViewController () <IngredientTableViewCellDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate> {}

#pragma mark - Private Properties

/**	An array of ingredient dictionaries filtered by the user's search.	*/
@property (nonatomic, strong)	NSArray						*filteredIngredients;
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
/**	The constraints used to set the search bar on top of the table view.	*/
@property (nonatomic, strong)	NSArray						*searchBarConstraints;
/**	This is the controller, handling presentation of results from the user's search. */
@property (nonatomic, strong)	UISearchDisplayController	*searchDisplay;
/**	An array of the titles to be used for the sections in the table view.	*/
@property (nonatomic, strong)	NSArray						*sectionTitles;
/**	An array of currently selected ingredient dictioanries, either included or excluded.	*/
@property (nonatomic, strong)	NSMutableDictionary			*selectedIngredients;
/**	The table view used to display all of the ingredients.	*/
@property (nonatomic, strong)	UITableView					*tableView;

@end

#pragma mark - Cupboard View Controller Implementation

@implementation CupboardViewController {}

#pragma mark - Action & Selector Methods

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
 *	@param	notification			The object containing a name, an object, and an optional dictionary.
 */
- (void)yummlyRequestHasBeenReset:(NSNotification *)notification
{
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
	
	NSArray *constraints;
	NSLayoutConstraint *constraint;
	
	//	add the table view to cover the whole main view except for the search bar
	constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]-(Panel)-|" options:kNilOptions metrics:@{@"Panel": @(kPanelWidth)} views:self.viewsDictionary];
	[self.view addConstraints:constraints];
	
	constraint							= [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
	[self.view addConstraint:constraint];
	
	self.searchBarConstraints			= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar][tableView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:self.viewsDictionary];
	[self.view addConstraints:self.searchBarConstraints];
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
	
	if (tableView == self.searchDisplay.searchResultsTableView)
		ingredientDictionary			= self.filteredIngredients[indexPath.row];
	else
		ingredientDictionary			= self.ingredientsForTableView[self.sectionTitles[indexPath.section]][indexPath.row];
	
	return ingredientDictionary;
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
	self.filteredIngredients			= [self.ingredientsMetadata filteredArrayUsingPredicate:predicate];
}

/**
 *	Sets the the search display controller's table view properties.
 */
- (void)sortOutSearchDisplayControllerTableView
{
	_searchDisplay.searchResultsDataSource	= self;
	_searchDisplay.searchResultsDelegate	= self;
	_searchDisplay.searchResultsTableView.allowsMultipleSelection	= YES;
	[_searchDisplay.searchResultsTableView registerClass:[IngredientTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
	//	initialise arrays to hold every selected ingredient, included or excluded
	NSMutableArray *allExcluded			= [[NSMutableArray alloc] init];
	NSMutableArray *allIncluded			= [[NSMutableArray alloc] init];
	
	for (NSDictionary *ingredientDictionary in self.selectedIngredients[kExcludedSelections])
		[allExcluded addObject:ingredientDictionary];
	for (NSDictionary *ingredientDictionary in self.selectedIngredients[kIncludedSelections])
		[allIncluded addObject:ingredientDictionary];
	
	NSArray *update						= @[ingredientDictionary];
	
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

#pragma mark - Setter & Getter Methods

/**
 *	An array of the ingredients filtered according to the search for the user.
 *
 *	@return	An initialised and empty array to be used to hold the user's search results.
 */
- (NSArray *)filteredIngredients
{
	if (!_filteredIngredients)
		_filteredIngredients			= @[];
	
	return _filteredIngredients;
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
		_searchBar.placeholder			= [[NSString alloc] initWithFormat:@"%@...", self.placeholders[arc4random() % self.placeholders.count]];
		_searchBar.searchBarStyle		= UISearchBarIconSearch;
		_searchBar.showsScopeBar		= NO;
		[ThemeManager customiseSearchBar:_searchBar withTheme:nil];
		
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
		[self sortOutSearchDisplayControllerTableView];
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
		_selectedIngredients				= [@{ kExcludedSelections	: @[],
											  kIncludedSelections	: @[]} mutableCopy];
	
	return _selectedIngredients;
}

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
	_leftDelegate					= leftDelegate;
	
	//	get a weak pointer to our self to be used in the block
	__weak CupboardViewController *weakSelf	= self;
	
	//	if a valid left delegate was set we send it the block to execute if it modifies any of our data
	if (_leftDelegate)
		[_leftDelegate blockToExecuteWhenDataModified:^(NSDictionary *modifiedIngredient)
		{
			dispatch_async(dispatch_queue_create("Modifying Selections", NULL),
			^{
				NSIndexPath *indexPath			= [weakSelf indexPathForIngredientDictionary:modifiedIngredient
																		  inTableView:weakSelf.tableView];
				IngredientTableViewCell *cell	= (IngredientTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
				
				if (!cell)
					cell						= (IngredientTableViewCell *)[weakSelf tableView:weakSelf.tableView
																		 cellForRowAtIndexPath:indexPath];
				
				dispatch_async(dispatch_get_main_queue(),
				^{
					[self.searchDisplayController setActive:NO animated:YES];
					
					if (cell.excluded)
						[cell setExcluded:NO updated:YES animated:NO];
					else if (cell.included)
						[cell setIncluded:NO updated:YES animated:NO];
					
					[self.tableView reloadRowsAtIndexPaths:@[indexPath]
										  withRowAnimation:UITableViewRowAnimationAutomatic];
				});
			});
		}];
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
		[self.view addSubview:_tableView];
		
		[_tableView registerClass:[IngredientTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
		
		_tableView.translatesAutoresizingMaskIntoConstraints	= NO;
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
	return @{	@"searchBar"	: self.searchBar,
				@"tableView"	: self.tableView};
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
	
	[self sortOutSearchDisplayControllerTableView];
	
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
	[self filterContentForSearchText:searchString inScope:nil];
	
	return YES;
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